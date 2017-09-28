defmodule Victor.Migration do
  defmacro __using__(_) do
    quote do
      import Ecto.Migration, except: [timestamps: 0, timestamps: 1]
      @disable_ddl_transaction false
      import unquote(__MODULE__)
      @before_compile Ecto.Migration
    end
  end

  def timestamps(opts \\ []) do
    opts
    |> Keyword.put(:type, :utc_datetime)
    |> Ecto.Migration.timestamps()
  end

  defmacro deleted_at do
    quote do
      add :deleted_at, :utc_datetime
    end
  end
end
