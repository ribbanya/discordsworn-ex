defmodule Discordsworn.Commands.Oracle.Table do
  @behaviour Nosedrum.Command
  @moduledoc false

  alias Nostrum.Struct.{Embed, User}
  alias Nostrum.Api
  import Nostrum.Struct.Embed
  import Discordsworn.Commands.Helper
  alias Discordsworn.Ecto.OracleHelper

  @impl true
  def usage, do: ["TODO"]

  @impl true
  def description, do: "TODO"

  @impl true
  def predicates, do: []

  @impl true
  def parse_args(args), do: args

  @impl true
  def command(msg, args) do
    {:ok, _msg} = reply(msg, args)
  end

  defp reply(msg, args) do
    content = create_content(args)
    Api.create_message(msg.channel_id, content: content)
  end

  defp create_content(args) do
    args
    |> Enum.map(&OracleHelper.roll/1)
    |> Enum.join(", ")
  end
end
