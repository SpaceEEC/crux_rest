# Crux.Rest

Package providing rest functions and rate limiting for the [Discord API](https://discordapp.com/developers).

## Useful links

 - [Documentation](https://hexdocs.pm/crux_rest/0.1.7/)
 - [Github](https://github.com/SpaceEEC/crux_rest/)
 - [Changelog](https://github.com/SpaceEEC/crux_rest/releases/tag/0.1.7/)
 - [Umbrella Development Documentation](https://crux.randomly.space/)

## Installation

The package can be installed by adding `crux_rest` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:crux_rest, "~> 0.1.7"}
  ]
end
```

## Usage

After providing a token to use via either your [config.exs](/config/config.exs), [`Application.put_env/3`](https://hexdocs.pm/elixir/Application.html#put_env/3), or [`:application.set_env/3`](http://erlang.org/doc/apps/kernel/application.html#set_env-3) freely use the functions provided by the [`Crux.Structs.Rest`](/lib/rest.ex) module.

For example:

```elixir
  iex> defmodule MyBot.Rest do
  ...>   use Crux.Rest
  ...> end
  {:module, MyBot.Rest, <<...>>, :ok}

  iex> {:ok, pid} = MyBot.Rest.start_link(token: "token", retry_limit: 3)
  {:ok, #PID<0.100.0>}

  iex> MyBot.Rest.create_message!(445290716198076427, content: "Hello there!")
  %Crux.Structs.Message{
    content: "Hello there!",
    author: %Crux.Structs.User{...},
    ...
  }
```