defmodule Discordsworn.Commands.Repeat do
  @behaviour Nosedrum.Command
  @moduledoc false

  alias Nostrum.Api
  alias Nostrum.Struct.{Embed, User}
  alias Nosedrum.Invoker.Split, as: CommandInvoker
  alias Nosedrum.Storage.ETS, as: CommandStorage
  alias Discordsworn.{Repo, Commands.Helper}
  alias Discordsworn.Ecto.Schema.Channel

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
    {:ok, msg} = reply(msg, args)
    {:skip_record, msg}
  end

  defp reply(msg, _args) do
    msg
    |> put_last_command()
    |> case do
      {:ok, msg} ->
        CommandInvoker.handle_message(msg, CommandStorage)

      {:error, reason} ->
        embed =
          %Embed{}
          |> Helper.put_provider()
          |> Embed.put_color(0xFF_00_00)
          |> Embed.put_title("Error")
          |> Embed.put_description(reason)

        Api.create_message(msg.channel_id, content: User.mention(msg.author), embed: embed)
    end
  end

  defp put_last_command(msg) do
    Repo.get_by(Channel, discord_id: msg.channel_id)
    |> case do
      nil ->
        {:error, "No command has been used here."}

      channel ->
        {:ok, Map.put(msg, :content, channel.last_command)}
    end
  end
end
