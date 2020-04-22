defmodule Crux.Rest.Endpoints.Generator do
  @moduledoc false
  @moduledoc since: "0.3.0"

  # Module used to generate endpoint functions via (nested) macros.
  # Example
  # defmodule Test do
  #   use Crux.Rest.Endpoints.Generator
  #   route "/foo/:foo_id"
  #   route "/bar" do
  #     route "foo/:foo_id"
  #   end
  # end

  # Usage then
  # Test.foo() # "/foo"
  # Test.foo(123) # "/foo/123"
  # Test.bar() # "/bar"
  # Test.bar_foo() # "/bar/foo"
  # Test.bar_foo(123) # "/bar/foo/123"

  # Import this module, add relevant attributes, and define a before compile callback.
  defmacro __using__([]) do
    quote do
      import unquote(__MODULE__), only: [route: 1, route: 2]
      @current []
      @routes %{}

      @before_compile {unquote(__MODULE__), :define_functions}
    end
  end

  @doc ~S"""
  Registers a route.

  This will generate functions to access it or part of it.
  Additionally if there are variable sements, those can be passed as arguments to it.

  For example:
  `route "/users/:user_id"`

  Will generate something equivalent to:
  ```elixir
  def users() do
    "/users"
  end

  def users(user_id) do
    "/users/#{user_id}"
  end
  ```
  """
  defmacro route(name) do
    put_route(name, do: nil)
  end

  @doc """
  Registers a route and allow nested routes to be created by using do blocks.

  This works the same as `route/1`.

  For example:
  ```elixir
  route "/users" do
    route "/:user_id"
    route "/@me"
  end
  ```

  Is equivalent to:
  ```elixir
  route "/users"
  route "/users/:user_id"
  route "/users/@me"
  ```
  """
  defmacro route(name, do: nested_routes) do
    put_route(name, do: nested_routes)
  end

  # Actually registers routes.
  defp put_route("/" <> name, do: nested_routes) do
    quote do
      # Save the current path
      current = @current

      # Add the new path to the current one
      @current current ++ unquote(String.split(name, "/"))

      # Ensure that nested resources get created too
      keys = Enum.map(@current, &Access.key(&1, %{}))

      # Create new resources
      @routes update_in(@routes, keys, fn %{} -> %{} end)

      # Recurse do blocks
      unquote(nested_routes)

      # Restore the saved path
      @current current
    end
  end

  defp put_route(name, do: _nested_routes) do
    raise "Routes must start with a /, got: \"#{name}\""
  end

  # Flattens the nested map stucture to a list of routes
  # %{"foo" => %{"bar" => {}, "baz" => %{}}}
  # to:
  # ["/foo", "/foo/bar", "/foo/baz"]
  defp flatten_routes(prefix \\ "", routes)

  defp flatten_routes(prefix, routes)
       when map_size(routes) > 0 do
    routes
    |> Enum.map(fn {route, children} ->
      route = "#{prefix}/#{route}"
      [route | [flatten_routes(route, children)]]
    end)
    |> List.flatten()
  end

  defp flatten_routes(_prefix, %{}) do
    []
  end

  # Before compile callback function to generate functions for the routes
  defmacro define_functions(%{module: module}) do
    routes =
      module
      |> Module.get_attribute(:routes)
      |> flatten_routes()

    Module.delete_attribute(module, :current)
    Module.delete_attribute(module, :routes)

    Enum.map(routes, &define_function/1)
  end

  defp define_function(route) do
    {function_name, function_arguments, function_return} = transform_route(route)

    quote do
      @doc """
      This functions handles the route:
      `#{unquote(route)}`.
      """
      # credo:disable-for-next-line Credo.Check.Readability.Specs
      def unquote(function_name)(unquote_splicing(function_arguments)) do
        unquote(function_return)
      end
    end
  end

  # Transforms a given route into:
  # - A function name out of the fix segments
  # - A list of variable ASTs out of the variable segments
  # - A return AST to return a formatted binary
  defp transform_route(route) do
    {fix, variable} = split_route(route)

    function_name = to_name(fix)
    function_arguments = to_arguments(variable)
    function_return = to_return(fix, variable)

    {function_name, function_arguments, function_return}
  end

  # Splits the route into its variable and fix segments.
  @spec split_route(route :: String.t()) :: {fix :: [String.t()], variable :: [String.t()]}
  defp split_route("/" <> route) do
    route
    |> String.split("/")
    |> Enum.split_with(fn
      ":" <> _segment -> false
      _segment -> true
    end)
  end

  # Joins the fix segments to a function name atom.
  @spec to_name([String.t()]) :: atom()
  defp to_name(segments) do
    segments
    |> Enum.map_join("_", fn
      "@me" -> "me"
      segment -> String.replace(segment, "-", "_")
    end)
    |> String.to_atom()
  end

  # Maps the variable segments to a list of variable ASTs to be used as function arguments.
  defp to_arguments(segments) do
    Enum.map(segments, &to_variable/1)
  end

  # Converts the given fix and evaluated variable segments into a binary joining them by "/".
  defp to_return(fix, variable) do
    quote do
      IO.iodata_to_binary(unquote(_to_return(fix, variable)))
    end
  end

  defp _to_return(fix, []) do
    Enum.map(fix, &["/", &1])
  end

  defp _to_return([], variable) do
    Enum.map(variable, &["/", to_string_variable(&1)])
  end

  defp _to_return([h_fix | t_fix], [h_var | t_var]) do
    ["/", h_fix, "/", to_string_variable(h_var) | _to_return(t_fix, t_var)]
  end

  ### Helpers

  # Converts a single name to the AST of a variable
  defp to_variable(":" <> name), do: to_variable(name)

  defp to_variable(name) do
    name
    |> String.to_atom()
    |> Macro.var(Elixir)
  end

  # Returns AST to `to_string/1` the given name as a variable in the current context.
  defp to_string_variable(name) do
    quote do
      to_string(unquote(to_variable(name)))
    end
  end
end
