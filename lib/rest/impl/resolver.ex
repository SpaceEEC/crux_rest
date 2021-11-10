defmodule Crux.Rest.Impl.Resolver do
  @moduledoc false
  @moduledoc since: "0.3.0"

  alias Crux.Structs

  alias Crux.Structs.{
    Overwrite,
    Permissions,
    Role,
    Snowflake,
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
  Resolves image data as per Discord's specification: [Discord Developer Documentation](https://discord.com/developers/docs/reference#image-data)
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

  # Role
  def resolve_overwrite(%{type: 0, id: id} = overwrite) do
    %{overwrite | id: resolve!(id, Role)}
    |> resolve_custom(:allow, &Permissions.resolve/1)
    |> resolve_custom(:deny, &Permissions.resolve/1)
  end

  # Member
  def resolve_overwrite(%{type: 1, id: id} = overwrite) do
    %{overwrite | id: resolve!(id, User)}
    |> resolve_custom(:allow, &Permissions.resolve/1)
    |> resolve_custom(:deny, &Permissions.resolve/1)
  end

  # Try to infer
  def resolve_overwrite(%{id: %{} = id} = overwrite)
      when not is_map_key(overwrite, :type) do
    overwrite =
      if id = Structs.resolve_id(id, Role) do
        overwrite
        |> Map.put(:id, id)
        |> Map.put(:type, 0)
      else
        id = Structs.resolve_id(id, User)

        overwrite
        |> Map.put(:id, id)
        |> Map.put(:type, 1)
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

  @spec resolve_message_reference(nil | map()) :: nil | map()
  def resolve_message_reference(nil) do
    nil
  end

  def resolve_message_reference(message_reference) do
    message_reference
    |> resolve_option(:message_id, Message)
    |> resolve_option(:channel_id, Channel)
    |> resolve_option(:guild_id, Guild)
  end

  @spec resolve_files(map()) :: {body :: term(), headers :: keyword()}
  def resolve_files(%{files: files} = opts) do
    {multipart_files, attachments} =
      files
      |> Enum.with_index()
      |> Enum.reduce({[], []}, fn
        {file, index}, {multipart_files, attachments} ->
          {attachment, name, attachments} =
            case file do
              {attachment, name} ->
                {attachment, name, attachments}

              {attachment, name, description} ->
                {attachment, name,
                 [%{id: index, filename: name, description: description} | attachments]}
            end

          disposition = {"form-data", [{"name", "files[#{index}]"}, {"filename", "\"#{name}\""}]}
          headers = [{:"content-type", :mimerl.filename(name)}]
          multipart_file = {name, attachment, disposition, headers}

          {[multipart_file | multipart_files], attachments}
      end)

    opts =
      if attachments != [] do
        Map.put(opts, :attachments, attachments)
      else
        opts
      end

    # If opts contains more than files, prepend payload_json
    form_data =
      if map_size(opts) > 1 do
        payload_json =
          opts
          |> Map.delete(:files)
          |> Jason.encode!()

        [{"payload_json", payload_json} | multipart_files]
      else
        multipart_files
      end

    {{:multipart, form_data}, [{:"content-type", "multipart/form-data"}]}
  end

  def resolve_files(%{} = opts) do
    {opts, []}
  end

  def resolve_application_command_id!(%{id: id}) do
    resolve_application_command_id!(id)
  end

  def resolve_application_command_id!(id) do
    Snowflake.to_snowflake(id)
  end

  def resolve_application_command!(%{} = command) do
    command
  end

  def resolve_application_command!(command_mod)
      when is_atom(command_mod) do
    unless Code.ensure_loaded?(command_mod) do
      raise ArgumentError, """
      Failed to resolve the given atom to an application command module.
      Recevied: #{command_mod}

      Failed to load the module.
      """
    end

    if function_exported?(command_mod, :__crux_command__, 0) do
      command_mod.__crux_command__()
    else
      raise ArgumentError, """
      Failed to resolve the given atom to an application command module.
      Recevied: #{command_mod}

      The loaded module does not seem to be an application command module.
      """
    end
  end
end
