defmodule Authority.Clients do
  @config Application.get_env(:authority, :clients)

  def fetch(client_id) do
    case Enum.find(@config, &(&1.client_id == client_id)) do
      nil -> {:error, :missing_client}
      client -> {:ok, client}
    end
  end

  def fetch(client_id, redirect_uri) do
    case Enum.find(@config, &(&1.client_id == client_id && &1.redirect_uri == redirect_uri)) do
      nil -> {:error, :missing_client}
      client -> {:ok, client}
    end
  end

  def secret_match?(client, secret) do
    if client.secret == secret do
      :ok
    else
      {:error, :missing_client}
    end
  end
end
