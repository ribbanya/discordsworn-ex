defmodule Discordsworn.Ecto.Schema.OracleColumn do
  use Ecto.Schema
  import Ecto.Changeset
  alias Discordsworn.Ecto.Schema.{Oracle, OracleRow}

  schema "oracle_columns" do
    belongs_to(:row, OracleRow)
    field(:index, :integer)
    field(:title, :string)
    has_one(:child, Oracle, foreign_key: :parent_id)
  end

  def changeset(column, params \\ %{}) do
    column
    |> cast(params, [:row_id, :index, :title])
    |> validate_required([:row_id, :index])
    |> foreign_key_constraint(:row_id)
    |> cast_assoc(:child)
  end
end
