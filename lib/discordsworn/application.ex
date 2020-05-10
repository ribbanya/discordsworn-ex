defmodule Discordsworn.Application do
  use Application

  def start(_type, _args) do
    # import Supervisor.Spec

    # List comprehension creates a consumer per cpu core
    # consumer_workers =
    # for i <- 1..System.schedulers_online(), do: worker(Discordsworn.Consumer, [], id: i)

    children = [Discordsworn.Consumer, Nosedrum.Storage.ETS, Discordsworn.Repo]

    :ets.new(Discordsworn.Session, [:set, :public, :named_table])
    ExDiceRoller.start_cache()

    Supervisor.start_link(children, strategy: :one_for_one, name: Discordsworn.Supervisor)
  end
end
