defmodule Discordsworn.Repo.Migrations.CreatePackagesTable do
  use Ecto.Migration

  @table :packages
  def change do
    create table(@table) do
      add(:uuid, :uuid, null: false)
      add(:uri, :text)
      timestamps(type: :utc_datetime)
    end

    create(unique_index(@table, :uuid))
  end
end
