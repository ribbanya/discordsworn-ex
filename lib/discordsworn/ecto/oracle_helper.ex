defmodule Discordsworn.Ecto.OracleHelper do
  require Ecto.Query
  import Ecto.Query
  alias Discordsworn.Repo
  alias Discordsworn.Ecto.Schema.{OracleAlias, OracleRow, OracleColumn}

  def roll(alias) do
    oracle_id =
      from(a in OracleAlias, where: a.key == ^alias, select: a.oracle_id, limit: 1)
      |> Repo.one!()

    row_subquery = from(OracleRow, where: [oracle_id: ^oracle_id]) |> subquery()

    max =
      from(r in row_subquery,
        select: r.threshold,
        order_by: [desc: r.threshold],
        limit: 1
      )
      |> Repo.one!()

    row_query =
      from(r in row_subquery,
        where: r.threshold >= ^Enum.random(1..max),
        order_by: r.threshold,
        select: r.id,
        limit: 1
      )

    column_query =
      from(c in OracleColumn,
        join: r in subquery(row_query),
        on: c.row_id == r.id,
        select: c.title
      )

    Repo.all(column_query) |> IO.inspect()
  end
end
