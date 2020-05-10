defmodule Discordsworn.Ecto.Schema.Oracle do
  use Ecto.Schema
  alias Discordsworn.Ecto.Schema.{OracleRow, OracleColumn, OracleAlias, Package}
  alias Discordsworn.Ecto.Types.{OracleBehaviour}
  import Ecto.Changeset

  schema "oracles" do
    belongs_to(:package, Package)
    field(:title, :string)
    has_many(:rows, OracleRow)
    has_many(:aliases, OracleAlias)
    belongs_to(:parent, OracleColumn)
    field(:behaviour, OracleBehaviour, default: :columns)
  end

  def changeset(oracle, params \\ %{}) do
    oracle
    |> cast(params, [:package_id, :title, :parent_id, :behaviour])
    |> foreign_key_constraint(:package_id)
    |> foreign_key_constraint(:parent_id)
    |> cast_assoc(:rows)
    |> cast_assoc(:aliases)
  end
end
