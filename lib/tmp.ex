defmodule Test do
  def start(name \\ Name) do
    Crux.Rest.Handler.Supervisor.start_link(
      {name,
       %{retry_limit: 5, token: "MjQyNjg1MDgwNjkzMjQzOTA2.D0b1wg.vmLfY-yz9ukvbuSdWh_cJqW8kZ0"}}
    )
  end

  def create(content, name \\ Name) do
    r = Crux.Rest.Functions.create_message(316_880_197_314_019_329, content: content)

    Crux.Rest.Handler.queue(name, r)
  end

  def get(id, name \\ Name) do
    r = Crux.Rest.Functions.get_message(316_880_197_314_019_329, id)

    Crux.Rest.Handler.queue(name, r)
  end

  def react(id, reaction, name \\ Name) do
    r = Crux.Rest.Functions.create_reaction(316_880_197_314_019_329, id, reaction)

    Crux.Rest.Handler.queue(name, r)
  end
end

defmodule Test2 do
  use Crux.Rest
end
