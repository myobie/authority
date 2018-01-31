defmodule Authority.Schema do
  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      @timestamps_opts [type: :utc_datetime, usec: true]
      alias Ecto.Changeset
      import Changeset, except: [validate_length: 3]
      import unquote(__MODULE__)
    end
  end

  alias Ecto.Changeset

  defmacro deleted_at do
    quote do
      field(:deleted_at, :utc_datetime)
    end
  end

  @spec fetch_fields(Changeset.t(), list(atom)) :: Keyword.t()
  def fetch_fields(changeset, fields), do: fetch_fields([], changeset, fields)

  @spec fetch_fields(Keyword.t(), Changeset.t(), nonempty_list(atom)) :: Keyword.t()
  defp fetch_fields(results, _changeset, []), do: results

  defp fetch_fields(results, changeset, [field | fields]) do
    value =
      case Changeset.fetch_field(changeset, field) do
        :error -> nil
        {_, v} -> v
      end

    results
    |> Keyword.put(field, value)
    |> fetch_fields(changeset, fields)
  end

  @spec truncate_length(Changeset.t(), atom | nonempty_list(atom), non_neg_integer) ::
          Changeset.t()
  def truncate_length(changeset, [], _size), do: changeset

  def truncate_length(changeset, [field | fields], size) do
    changeset
    |> truncate_length(field, size)
    |> truncate_length(fields, size)
  end

  def truncate_length(changeset, field, size) when is_atom(field) do
    changeset
    |> Changeset.update_change(field, &String.slice(&1, 0, size))
  end

  @spec validate_length(Changeset.t(), atom | nonempty_list(atom), Keyword.t()) :: Changeset.t()
  def validate_length(changeset, [], _options), do: changeset

  def validate_length(changeset, [field | fields], options) do
    changeset
    |> validate_length(field, options)
    |> validate_length(fields, options)
  end

  def validate_length(changeset, field, options) when is_atom(field) do
    changeset
    |> Changeset.validate_length(field, options)
  end
end
