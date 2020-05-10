defmodule Discordsworn.Ecto.Schema.Package do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ecto.UUID
  alias Discordsworn.Ecto.Schema.{Oracle}

  schema "packages" do
    field(:uuid, UUID)
    field(:uri, :string)
    has_many(:oracles, Oracle)

    timestamps(type: :utc_datetime)
  end

  def changeset(package, params \\ %{}) do
    package
    |> cast(params, [:uuid, :uri])
    |> cast_assoc(:oracles)
    |> validate_required([:uuid])
    |> unique_constraint([:uuid])
  end
end
