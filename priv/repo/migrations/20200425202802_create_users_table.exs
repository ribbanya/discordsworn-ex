defmodule Discordsworn.Repo.Migrations.CreateUsersTable do
  use Ecto.Migration

  @table :users
  def change do
    create(table(@table)) do
      add(:discord_id, :bit, size: 64)
      add(:admin?, :boolean, null: false, default: false)
      timestamps(type: :utc_datetime)
    end
  end
end
