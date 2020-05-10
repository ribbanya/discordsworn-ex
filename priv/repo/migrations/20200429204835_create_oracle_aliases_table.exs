defmodule Discordsworn.Repo.Migrations.CreateOracleAliasesTable do
  use Ecto.Migration

  @table :oracle_aliases
  def change do
    create(table(@table)) do
      add(:key, :citext, null: false)
      add(:oracle_id, references(:oracles, on_delete: :delete_all))
    end

    create(unique_index(@table, :key))
    create(index(@table, :oracle_id))
  end
end
