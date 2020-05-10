defmodule Discordsworn.Ecto.Schema.Channel do
  use Ecto.Schema
  alias Discordsworn.Ecto.Types.Snowflake
  import Ecto.Changeset

  schema "channels" do
    field(:discord_id, Snowflake)
    field(:last_command, :string)
    timestamps(type: :utc_datetime)
  end

  def changeset(channel, params \\ %{}) do
    channel
    |> cast(params, [:discord_id, :last_command])
    |> Snowflake.validate(:discord_id)
  end
end
