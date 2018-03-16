# Authority

An OpenID Connect compatible authorization server providing a JSON API.
_Not yet, but working on it._

## Current state

Right now all this OP can do is the implicit flow and only the `id_token`
response type. It does have the ability to merge email into the `id_token`
using the `claims` param.

An example of a URL that might should work is:

```
http://auth.example.com/authorize?provider=github&response_type=id_token&client_id=abcdefg&redirect_uri=https%3A%2F%2Fother.example.com%2Fauth%2Fcallback&scope=openid%20profile&nonce=123456&state=xyz&claims=%7B%22id_token%22%3A%7B%22email%22%3A%7B%22essential%22%3Atrue%7D%7D%7D
```

## Development

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## How do I generate a keypair?

```sh
$ mix keypair
```

# TODO:

- [x] Get `/authorize` to do the most basic happy path implicit flow as a proof of concept
- [x] Validate the `provider` param in `/authorize`
- [x] Fix merge accounts test
- [x] Document how to create public/private key pairs (JWKs)
- [x] Make it possible for clients to limit their allowed providers
- [ ] Authorization code flow
- [ ] Add a few more providers for testing
- [ ] User info API
- [ ] Identities API
- [ ] Start an `authority_client` library for use in Plug/Phoenix applications
- [ ] Start an `ueberauth` strategy
- [ ] What to do with a provider that doesn't provide an email address?



**_Victor?_**

_I used to be named victor. That name was confusing so I got a more generic and
appropriate name. Just in case you run into any code or file named victor._
