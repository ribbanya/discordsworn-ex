defmodule Discordsworn.Repo.Migrations.CreateOraclesResultsRowsTables do
  use Ecto.Migration

  @table :oracle_rows
  def change do
    create(table(@table)) do
      add(:oracle_id, references(:oracles, on_delete: :delete_all), null: false)
      add(:threshold, :integer, null: false)
      add(:title, :text)
    end

    create(unique_index(@table, [:oracle_id, :threshold]))
    create(constraint(@table, "#{@table}_threshold_gteq_0", check: ~s|"threshold" >= 0|))
  end
end
