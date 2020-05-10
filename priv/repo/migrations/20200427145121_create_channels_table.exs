defmodule Discordsworn.Repo.Migrations.CreateChannelsTable do
  use Ecto.Migration

  @table :channels
  def change do
    create(table(@table)) do
      add(:discord_id, :bit, size: 64)
      add(:last_command, :text)
      timestamps(type: :utc_datetime)
    end
  end
end
