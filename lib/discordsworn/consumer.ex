defmodule Discordsworn.Consumer do
  use Nostrum.Consumer
  require Logger
  alias Nostrum.{Snowflake, Struct.Message}
  alias Nosedrum.Invoker.Split, as: CommandInvoker
  alias Nosedrum.Storage.ETS, as: CommandStorage
  alias Discordsworn.Commands.{Account, Ironsworn, Oracle, Repeat}
  alias Discordsworn.Repo
  alias Discordsworn.Ecto.Schema.Channel

  @commands %{
    "is" => Ironsworn.Action,
    "o" => %{:default => Ironsworn.AskTheOracle, "upload" => Oracle.Upload, "t" => Oracle.Table},
    "who" => Account.WhoIs,
    "." => Repeat
  }

  def start_link do
    Nostrum.Consumer.start_link(__MODULE__)
  end

  def handle_event({:READY, _data, _ws_state}) do
    init_session_table()
    add_commands()
  end

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    case CommandInvoker.handle_message(msg, CommandStorage) do
      {:skip_record, reply} ->
        {:ok, reply}

      {:ok, reply} ->
        record_last_command(msg)
        {:ok, reply}

      other ->
        other
    end
  end

  def handle_event(_data), do: :ok

  defp init_session_table() do
    owner_id =
      Application.get_env(:discordsworn, :owner_discord_id)
      |> Snowflake.cast!()

    :ets.insert(Discordsworn.Session, {:owner_id, owner_id})
  end

  defp add_commands() do
    Enum.each(@commands, fn {name, cmd} ->
      CommandStorage.add_command({name}, cmd)
      Logger.debug("Added command '#{name}': #{inspect(cmd)}")
    end)
  end

  defp record_last_command(%Message{content: text, channel_id: channel_id}) do
    Repo.get_by(Channel, discord_id: channel_id)
    |> case do
      nil -> %Channel{discord_id: channel_id}
      channel -> channel
    end
    |> Channel.changeset(%{last_command: text})
    |> Repo.insert_or_update()
    |> case do
      {:ok, _channel} -> :ok
      {:error, changeset} -> Logger.warn(changeset)
    end
  end
end
