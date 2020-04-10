defmodule Discordsworn do
  def start do
    import Supervisor.Spec

    # List comprehension creates a consumer per cpu core
    children =
      for i <- 1..System.schedulers_online(), do: worker(Discordsworn.Consumer, [], id: i)

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end

defmodule Discordsworn.Consumer do
  use Nostrum.Consumer

  alias Nostrum.Api

  require Logger

  def start_link do
    Nostrum.Consumer.start_link(__MODULE__)
  end

  def handle_event({:MESSAGE_CREATE, msg, state}) do
    case msg.content do
      "." <> _ ->
        Discordsworn.Commands.execute(msg, state)

      _ ->
        :ignore
    end
  end

  def handle_event(_event) do
    :noop
  end
end
