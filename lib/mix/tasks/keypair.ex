defmodule Mix.Tasks.Keypair do
  use Mix.Task

  @shortdoc "Generate a public/private keypair (using JOSE)"
  def run([]), do: run(["ES512"])

  def run([alg]) do
    key = JOSE.JWS.generate_key(%{"alg" => alg})
    public_key = JOSE.JWK.to_public(key)

    with {_, key_binary} <- JOSE.JWK.to_binary(key),
         {_, public_key_binary} <- JOSE.JWK.to_binary(public_key) do
      IO.puts("Keypair:")
      IO.puts(key_binary)
      IO.puts("")
      IO.puts("Public key:")
      IO.puts(public_key_binary)
      IO.puts("")

      IO.puts(
        "The private/public keypair is only for Authority. The public key is for any app that needs to verify signed JWT's created by Authority."
      )
    else
      error ->
        IO.puts("Error generating keypair: #{inspect(error)}")
        exit({:shutdown, 1})
    end
  end
end
