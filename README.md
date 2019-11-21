# Crux.Rest

Library providing rest functions and rate limiting for the [Discord API](https://discordapp.com/developers).

## Useful links

 - [Documentation](https://hexdocs.pm/crux_rest/0.2.1/)
 - [Github](https://github.com/SpaceEEC/crux_rest/)
 - [Changelog](https://github.com/SpaceEEC/crux_rest/releases/tag/0.2.1/)
 - [Umbrella Development Documentation](https://crux.randomly.space/)

## Installation

The library can be installed by adding `crux_rest` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:crux_rest, "~> 0.2.1"}
  ]
end
```

## Usage

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