defmodule Discordsworn.Ecto.Types.Snowflake do
  use Ecto.Type
  require Nostrum.Snowflake
  alias Nostrum.Snowflake

  def type, do: :bit

  def cast(term) when Snowflake.is_snowflake(term), do: {:ok, term}
  def cast(<<integer::64>>), do: {:ok, integer}
  def cast(_), do: :error

  def load(<<integer::64>>), do: {:ok, integer}
  def load(_), do: :error

  def dump(snowflake) when Snowflake.is_snowflake(snowflake) do
    {:ok, <<snowflake::size(64)>>}
  end

  def dump(_), do: :error

  def validate(changeset, field) when is_atom(field) do
    changeset
    |> Ecto.Changeset.validate_change(field, fn
      _f, v when Snowflake.is_snowflake(v) -> []
      f, _v -> [{f, "must be a snowflake"}]
    end)
  end
end
