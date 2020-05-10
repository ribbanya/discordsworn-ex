defmodule Discordsworn.Ecto.Schema.OracleRow do
  use Ecto.Schema
  import Ecto.Changeset
  alias Discordsworn.Ecto.Schema.{Oracle, OracleColumn}

  schema "oracle_rows" do
    field(:title, :string)
    belongs_to(:oracle, Oracle)
    field(:threshold, :integer)
    has_many(:columns, OracleColumn, foreign_key: :row_id)
  end

  def changeset(row, params \\ %{}) do
    row
    |> cast(params, [:title, :oracle_id, :threshold])
    |> foreign_key_constraint(:oracle_id)
    |> validate_number(:threshold, greater_than_or_equal_to: 0)
    |> cast_assoc(:columns)
  end
end
