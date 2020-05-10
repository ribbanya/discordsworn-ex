defmodule Discordsworn.Ecto.Schema.User do
  use Ecto.Schema
  alias Discordsworn.Ecto.Types.Snowflake
  import Ecto.Changeset

  schema "users" do
    field(:discord_id, Snowflake)
    field(:admin?, :boolean, default: false)
    timestamps(type: :utc_datetime)
  end

  def changeset(channel, params \\ %{}) do
    channel
    |> cast(params, [:discord_id, :last_command])
    |> Snowflake.validate(:discord_id)
    |> validate_required([:admin?])
  end
end
