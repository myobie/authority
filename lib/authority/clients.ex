defmodule Authority.Clients do
  @config Application.get_env(:authority, :clients)

  def fetch(client_id, redirect_uri) do
    case Enum.find(@config, &(&1.client_id == client_id && &1.redirect_uri == redirect_uri)) do
      nil -> {:error, :missing_client}
      client -> {:ok, client}
    end
  end
end
