defmodule Authority.Client do
  defstruct client_id: nil, client_secret: nil, redirect_uri: nil, allowed_providers: [], allowed_response_types: []

  @type t :: %__MODULE__{}

  def config, do: Authority.Client.Config.get()

  @spec fetch(String.t()) :: t
  def fetch(client_id) do
    case Enum.find(config(), &(&1.client_id == client_id)) do
      nil -> {:error, :missing_client}
      client -> {:ok, client}
    end
  end

  def fetch(client_id, redirect_uri) do
    case Enum.find(config(), &(&1.client_id == client_id && &1.redirect_uri == redirect_uri)) do
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

  def allowed_provider?(client, provider) do
    case client.allowed_providers do
      :none -> false
      [] -> true
      providers -> Enum.member?(providers, to_string(provider))
    end
  end

  def allowed_response_type?(client, response_type) do
    case client.allowed_response_types do
      :none -> false
      [] -> true
      types -> Enum.member?(types, to_string(response_type))
    end
  end
end
