defmodule Discordsworn.JSON.OracleImporter do
  alias Discordsworn.Ecto.Schema.{Package, Oracle, OracleAlias, OracleRow, OracleColumn}
  alias Ecto.{Multi, Changeset}
  import Ecto.Query

  @defaults [direction: :up]
  def import_file(path, opts \\ []) do
    path
    |> Path.expand()
    |> File.read!()
    |> Jason.decode!(keys: &decode/1)
    |> Map.put(:uri, Path.relative_to_cwd(path))
    |> import_package(Keyword.merge(@defaults, opts))
  end

  defp decode(key) do
    case Integer.parse(key) do
      {integer, "" = _binary} -> integer
      _not_integer -> String.to_existing_atom(key)
    end
  end

  defp import_package(package, opts) do
    Multi.new()
    |> do_down(package, opts)
    |> do_up(package, opts)
  end

  defp do_down(multi, %{uuid: uuid}, _opts) do
    multi
    |> Multi.run({:delete, [{Package, uuid}]}, fn repo, _changes ->
      case repo.get_by(Package, uuid: uuid) do
        nil -> {:ok, nil}
        package -> repo.delete(package)
      end
    end)
  end

  defp to_changeset(params, module) do
    Kernel.struct!(module)
    |> module.changeset(params)
  end

  defp push_breadcrumb(breadcrumbs, module, value) do
    [{module, value} | breadcrumbs]
  end

  defp get_last(changes, breadcrumbs) do
    changes[{:insert, breadcrumbs}]
  end

  def put_with_index(multi, breadcrumbs, enum, fun) do
    enum
    |> Enum.with_index()
    |> Enum.reduce(multi, fn {elem, index}, multi -> fun.(multi, breadcrumbs, elem, index) end)
  end

  defp do_up(multi, %{uuid: uuid} = package, direction: :up) do
    {oracles, package} = Map.pop(package, :oracles)

    {multi, breadcrumbs} = run_insert(multi, [], Package, uuid, package)

    multi
    |> put_with_index(breadcrumbs, oracles, &put_oracle/4)
  end

  defp do_up(multi, _package, direction: _), do: multi

  defp run_insert(multi, breadcrumbs, module, value, params, parent_key \\ nil) do
    breadcrumbs = push_breadcrumb(breadcrumbs, module, value)

    multi =
      Multi.run(multi, {:insert, breadcrumbs}, fn repo, changes ->
        params =
          case parent_key do
            nil ->
              params

            parent_key ->
              %{id: parent_id} = get_last(changes, tl(breadcrumbs))
              Map.put(params, parent_key, parent_id)
          end

        params
        |> to_changeset(module)
        |> repo.insert()
      end)

    {multi, breadcrumbs}
  end

  defp put_oracle(multi, breadcrumbs, oracle, index) do
    {aliases, oracle} = Map.pop(oracle, :aliases)
    {rows, oracle} = Map.pop(oracle, :rows)

    {multi, breadcrumbs} = run_insert(multi, breadcrumbs, Oracle, index, oracle, :package_id)

    multi
    |> put_aliases(breadcrumbs, aliases)
    |> put_rows(breadcrumbs, rows)
  end

  defp put_aliases(multi, breadcrumbs, aliases) do
    Enum.reduce(aliases, multi, &put_alias(&2, breadcrumbs, &1))
  end

  defp put_alias(multi, breadcrumbs, key) do
    {multi, _breadcrumbs} =
      run_insert(multi, breadcrumbs, OracleAlias, key, %{key: key}, :oracle_id)

    multi
  end

  defp put_rows(multi, breadcrumbs, rows) do
    Enum.reduce(rows, multi, fn {threshold, columns}, multi ->
      put_row(multi, breadcrumbs, threshold, columns)
    end)
  end

  defp put_row(multi, breadcrumbs, threshold, columns) when is_list(columns) do
    {multi, breadcrumbs} =
      run_insert(multi, breadcrumbs, OracleRow, threshold, %{threshold: threshold}, :oracle_id)

    multi
    |> put_with_index(breadcrumbs, columns, &put_column/4)
  end

  defp put_row(multi, breadcrumbs, threshold, column) do
    put_row(multi, breadcrumbs, threshold, [column])
  end

  defp put_column(multi, breadcrumbs, title, index) when is_binary(title) do
    put_column(multi, breadcrumbs, %{title: title}, index)
  end

  defp put_column(multi, breadcrumbs, column, index) do
    {child, column} = Map.pop(column, :child)
    column = Map.put(column, :index, index)

    {multi, breadcrumbs} = run_insert(multi, breadcrumbs, OracleColumn, index, column, :row_id)

    multi
    |> put_child(breadcrumbs, child)
  end

  defp put_child(multi, _breadcrumbs, nil = _child), do: multi

  defp put_child(multi, breadcrumbs, child) do
    {rows, child} = Map.pop(child, :rows)

    {multi, breadcrumbs} = run_insert(multi, breadcrumbs, Oracle, 0, child, :parent_id)

    multi
    |> put_rows(breadcrumbs, rows)
  end
end
