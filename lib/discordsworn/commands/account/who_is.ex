defmodule Discordsworn.Commands.Account.WhoIs do
  @behaviour Nosedrum.Command
  @moduledoc false

  alias Discordsworn.Commands.Helper

  @impl true
  def usage, do: ["TODO"]

  @impl true
  def description, do: "TODO"

  @impl true
  def predicates, do: []

  @impl true
  def command(msg, args) do
    {:ok, _msg} = reply(msg, args)
  end

  def reply(msg, args) do
    content = "<@#{parse_user_string(msg, Enum.at(args, 0))}>"
    Nostrum.Api.create_message(msg.channel_id, content: content)
  end

  defp parse_user_string(msg, string) do
    string
    |> String.trim()
    |> String.downcase()
    |> case do
      "me" -> msg.author.id
      "you" -> Nostrum.Cache.Me.get().id
      "owner" -> Helper.get_owner()
    end
  end
end
