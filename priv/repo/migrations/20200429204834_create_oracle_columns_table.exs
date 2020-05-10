defmodule Discordsworn.Repo.Migrations.CreateOracleColumnsTable do
  use Ecto.Migration

  @table :oracle_columns
  def change do
    create table(@table) do
      add(:row_id, references(:oracle_rows, on_delete: :delete_all), null: false)
      add(:index, :integer, null: false)
      add(:title, :text)
    end

    create(unique_index(@table, [:row_id, :index]))

    alter table(:oracles) do
      add(:parent_id, references(@table, on_delete: :delete_all))
    end
  end
end
