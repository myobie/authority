defmodule Authority.Client do
  defstruct client_id: nil, client_secret: nil, redirect_uri: nil, allowed_providers: [], allowed_response_types: []

  @type t :: %__MODULE__{}

  def config, do: Authority.Client.Config.get()

  @doc "Fetch a configured client by client_id"
  @spec fetch(String.t()) :: {:ok, t} | {:error, :missing_client}
  def fetch(client_id) do
    case Enum.find(config(), &(&1.client_id == client_id)) do
      nil -> {:error, :missing_client}
      client -> {:ok, client}
    end
  end

  @doc "Fetch a configured client by both client_id and redirect_uri"
  @spec fetch(String.t(), String.t()) :: {:ok, t} | {:error, :missing_client}
  def fetch(client_id, redirect_uri) do
    case Enum.find(config(), &(&1.client_id == client_id && &1.redirect_uri == redirect_uri)) do
      nil -> {:error, :missing_client}
      client -> {:ok, client}
    end
  end

  @doc ~S"""
  Compares a secret to a certain client's internal secret.

  ## Examples

      iex> Client.secret_match?(%Client{client_secret: "abc"}, "abc")
      :ok

      iex> Client.secret_match?(%Client{client_secret: "xyz"}, "abc")
      {:error, :missing_client}
  """
  @spec secret_match?(t, String.t()) :: :ok | {:error, :missing_client}
  def secret_match?(client, secret) do
    if client.client_secret == secret do
      :ok
    else
      {:error, :missing_client}
    end
  end

  @doc ~S"""
  Determines if a certain client allows a certain provider.

  ## Examples

      iex> Client.allowed_provider?(%Client{allowed_providers: :none}, "anything")
      false

      iex> Client.allowed_provider?(%Client{allowed_providers: ["github"]}, :github)
      true

      iex> Client.allowed_provider?(%Client{allowed_providers: ["github"]}, "github")
      true

      iex> Client.allowed_provider?(%Client{allowed_providers: [:github]}, :anything)
      false

      iex> Client.allowed_provider?(%Client{allowed_providers: []}, :anything)
      true
  """
  @spec allowed_provider?(t, String.t()) :: boolean
  def allowed_provider?(client, provider) do
    case client.allowed_providers do
      :none -> false
      [] -> true
      providers -> Enum.member?(providers, to_string(provider))
    end
  end

  @doc ~S"""
  Determines if a certain client allows a certain response type.

  ## Examples

      iex> Client.allowed_response_type?(%Client{allowed_response_types: :none}, "anything")
      false

      iex> Client.allowed_response_type?(%Client{allowed_response_types: ["id_token"]}, "id_token")
      true

      iex> Client.allowed_response_type?(%Client{allowed_response_types: ["id_token"]}, :id_token)
      true

      iex> Client.allowed_response_type?(%Client{allowed_response_types: ["id_token"]}, :other)
      false

      iex> Client.allowed_response_type?(%Client{allowed_providers: []}, :anything)
      true
  """
  @spec allowed_response_type?(t, String.t()) :: boolean
  def allowed_response_type?(client, response_type) do
    case client.allowed_response_types do
      :none -> false
      [] -> true
      types -> Enum.member?(types, to_string(response_type))
    end
  end
end
