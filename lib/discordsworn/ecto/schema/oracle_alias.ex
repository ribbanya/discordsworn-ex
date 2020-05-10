defmodule Discordsworn.Ecto.Schema.OracleAlias do
  use Ecto.Schema
  import Ecto.Changeset
  alias Discordsworn.Ecto.Schema.{Oracle}

  schema "oracle_aliases" do
    field(:key, :string)
    belongs_to(:oracle, Oracle)
  end

  def changeset(alias, params \\ %{}) do
    alias
    |> cast(params, [:key, :oracle_id])
    |> validate_required([:key, :oracle_id])
    |> validate_change(:key, fn :key, _key -> [] end)
    |> foreign_key_constraint(:oracle_id)
  end
end
