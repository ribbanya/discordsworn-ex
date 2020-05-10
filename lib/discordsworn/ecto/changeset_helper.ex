defmodule Discordsworn.Ecto.ChangesetHelper do
  import Ecto.Changeset
  require Nostrum.Snowflake

  def validate_index(changeset, constraint_columns) do
    constraint_columns = constraint_columns ++ [:index]

    changeset
    |> validate_required([:index])
    |> unique_constraint(constraint_columns)
  end
end
