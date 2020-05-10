defmodule Discordsworn.Repo.Migrations.CreateOraclesTable do
  use Ecto.Migration
  alias Discordsworn.Ecto.Types.{OracleBehaviour}

  @table :oracles
  def change do
    OracleBehaviour.create_type()

    create table(@table) do
      add(:package_id, references(:packages, on_delete: :delete_all))
      add(:title, :text)
      add(:behaviour, OracleBehaviour.type(), default: "columns")
    end
  end
end
