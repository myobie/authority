defmodule Authority.Client.Config do
  @config Application.get_env(:authority, :clients)
          |> Enum.map(fn info ->
            providers =
              info
              |> Map.get(:allowed_providers, [])
              |> Enum.map(&to_string/1)

            response_types =
              info
              |> Map.get(:allowed_response_types, [])
              |> Enum.map(&to_string/1)


            Authority.Client
            |> struct(info)
            |> Map.put(:allowed_providers, providers)
            |> Map.put(:allowed_response_types, response_types)
          end)

  def get, do: @config
end
