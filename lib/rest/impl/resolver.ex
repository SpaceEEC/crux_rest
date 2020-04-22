defmodule Crux.Rest.Impl.Resolver do
  @moduledoc false
  @moduledoc since: "0.3.0"

  alias Crux.Structs

  alias Crux.Structs.{
    Overwrite,
    Permissions,
    Role,
    User
  }

  @doc """
  Tries to resolve the id of `data` in the context of the `target` module.

  Returns `nil` if `data` is `nil`.
  Otherwise raises an argument error if resolving fails.
  """
  @spec resolve(term(), module()) :: nil | Structs.Snowflake.t()
  def resolve(data_or_nil, target)

  def resolve(nil, _target) do
    nil
  end

  def resolve(data, target) do
    resolve!(data, target)
  end

  @doc """
  Tries to resolve the id of `data` in the context of the `target` module.

  Raises an argument error if resolving fails.
  """
  @spec resolve!(term(), module()) :: Structs.Snowflake.t()
  def resolve!(data, target) do
    case Structs.resolve_id(data, target) do
      nil ->
        raise ArgumentError, """
        Could not resolve the id of #{target}:

        Got #{inspect(data)}
        """

      target_id ->
        target_id
    end
  end

  @doc """
  Tries to resolve a list of ids of `data` in `list` in the context of the `target` module.

  Raises an argument error if resolving of any `data` fails.
  """
  @spec resolve_list!(list(term()), module()) :: [Structs.Snowflake.t()]
  def resolve_list!(list, target) do
    Enum.map(list, &resolve!(&1, target))
  end

  @doc """
  Tries to resolve the id of an option identified by the given `key`
  in the given `options` map in the context of the `target` module.

  Does nothing if the `key` is not part of `options`.
  If the value is `nil`, nothing happens.
  Otherwise raises an argument error if resolving fails.
  """
  @spec resolve_option(map(), atom(), module()) :: map()
  def resolve_option(options, key, target)
      when is_map_key(options, key) do
    Map.update!(
      options,
      key,
      &resolve(&1, target)
    )
  end

  def resolve_option(options, _key, _target) do
    options
  end

  @doc """
  Tries to resolve the id of an option identified by the given `key`
  in the given `options` map in the context of the `target` module.

  Does nothing if the `key` is not part of `options`.
  Otherwise raises an argument error if resolving fails.
  """
  @spec resolve_option!(map(), atom(), module()) :: map()
  def resolve_option!(options, key, target)
      when is_map_key(options, key) do
    Map.update!(
      options,
      key,
      &resolve!(&1, target)
    )
  end

  def resolve_option!(options, _key, _target) do
    options
  end

  @doc """
  Resolves an option by a custom function.

  Does nothing if the `key` is not part of `options`.
  """
  @spec resolve_custom(map(), atom(), (term() -> term())) :: map()
  def resolve_custom(options, key, fun)
      when is_map_key(options, key) and is_function(fun, 1) do
    Map.update!(
      options,
      key,
      fun
    )
  end

  def resolve_custom(options, _key, fun)
      when is_function(fun, 1) do
    options
  end

  ###
  # Specific resolvers
  ###

  @doc """
  Resolves image data as per Discord's specification: [Discord Developer Documentation](https://discordapp.com/developers/docs/reference#image-data)
  """
  @spec resolve_image(image :: nil | String.t() | {extension :: String.t(), data :: binary()}) ::
          nil | String.t()
  def resolve_image(nil = image) do
    image
  end

  def resolve_image("data:image/" <> _bin = image) do
    image
  end

  def resolve_image({extension, data})
      when is_binary(extension) and is_binary(data) do
    "data:image/#{extension};base64,#{Base.encode64(data)}"
  end

  @spec resolve_permission_overwrites(list()) :: nil | [map()]
  def resolve_permission_overwrites(nil) do
    nil
  end

  def resolve_permission_overwrites(permission_overwrites) do
    Enum.map(permission_overwrites, &resolve_overwrite/1)
  end

  @spec resolve_overwrite(list() | map() | Overwrite.t()) :: map()
  def resolve_overwrite(%Overwrite{} = overwrite) do
    overwrite
  end

  def resolve_overwrite(%{type: "role", id: id} = overwrite) do
    %{overwrite | id: resolve!(id, Role)}
    |> resolve_custom(:allow, &Permissions.resolve/1)
    |> resolve_custom(:deny, &Permissions.resolve/1)
  end

  def resolve_overwrite(%{type: "member", id: id} = overwrite) do
    %{overwrite | id: resolve!(id, User)}
    |> resolve_custom(:allow, &Permissions.resolve/1)
    |> resolve_custom(:deny, &Permissions.resolve/1)
  end

  def resolve_overwrite(%{id: %{} = id} = overwrite)
      when not is_map_key(overwrite, :type) do
    overwrite =
      if id = Structs.resolve_id(id, Role) do
        overwrite
        |> Map.put(:id, id)
        |> Map.put(:type, "role")
      else
        id = Structs.resolve_id(id, User)

        overwrite
        |> Map.put(:id, id)
        |> Map.put(:type, "member")
      end

    overwrite
    |> resolve_custom(:allow, &Permissions.resolve/1)
    |> resolve_custom(:deny, &Permissions.resolve/1)
  end

  def resolve_overwrite(overwrite)
      when not is_map(overwrite) do
    overwrite
    |> Map.new()
    |> resolve_overwrite()
  end

  def resolve_overwrite(overwrite) do
    raise ArgumentError, """
    Expected a valid :type and :id or an :id that could be resolved to a :type.

    Received: #{inspect(overwrite)}
    """
  end

  @spec resolve_allowed_mentions(nil | map()) :: nil | map()
  def resolve_allowed_mentions(nil) do
    nil
  end

  def resolve_allowed_mentions(allowed_mentions) do
    allowed_mentions
    |> resolve_custom(:parse, &Enum.map(&1, fn v -> to_string(v) end))
    |> resolve_custom(:roles, &Enum.map(&1, fn role -> resolve!(role, Role) end))
    |> resolve_custom(:users, &Enum.map(&1, fn user -> resolve!(user, User) end))
  end

  @spec resolve_files(map()) :: {body :: term(), headers :: keyword()}
  def resolve_files(%{files: files} = opts) do
    multipart_files =
      Enum.map(files, fn {attachment, name} ->
        disposition = {"form-data", [{"filename", "\"#{name}\""}]}
        headers = [{"content-type", :mimerl.filename(name)}]

        {name, attachment, disposition, headers}
      end)

    form_data =
      # If opts contains more than files, prepend payload_json
      if map_size(opts) > 1 do
        payload_json =
          opts
          |> Map.delete(:files)
          |> Jason.encode!()

        [{"payload_json", payload_json} | multipart_files]
      else
        multipart_files
      end

    {{:multipart, form_data}, [{"content-type", "multipart/form-data"}]}
  end

  def resolve_files(%{} = opts) do
    {opts, []}
  end
end