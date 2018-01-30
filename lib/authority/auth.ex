defmodule Authority.Auth do
  alias Authority.{Account, Email, Identity, Repo}
  import Ecto.Query

  def process(%Ueberauth.Auth{} = auth) do
    case Repo.transaction(find_or_create(auth)) do
      {:ok, result} ->
        {:ok, result}
      {:error, failed_op, failed_value, changes} ->
        Repo.rollback(%{op: failed_op, value: failed_value, changes: changes})
      other ->
        IO.inspect(other)
        raise "what?"
    end
  end

  def find_or_create(auth) do
    case {find_email(auth), find_identity(auth)} do
      {nil, nil} ->
        insert_all(auth)
      {email, nil} ->
        insert_identity_related_to(email, auth)
      {nil, identity} ->
        insert_email_related_to(identity, auth)
      {email, identity} ->
        if email.account_id == identity.account_id do
          update_all(email, identity, auth)
        else
          merge_and_update_all(email, identity, auth)
        end
    end
  end

  def insert_all(auth) do
    # TODO: support providers that don't provide an email address

    Ecto.Multi.new
    |> Ecto.Multi.insert(:account, account_changeset(auth))
    |> Ecto.Multi.run(:email, fn %{account: account} ->
      Repo.insert(email_changeset(auth, account))
    end)
    |> Ecto.Multi.run(:identity, fn %{account: account} ->
      Repo.insert(identity_changeset(auth, account))
    end)
  end

  def insert_identity_related_to(email, auth) do
    %{account: account} = Repo.preload(email, :account)

    Ecto.Multi.new
    |> Ecto.Multi.run(:account, fn _ ->
      update_empty_account_info(account, auth)
    end)
    |> Ecto.Multi.insert(:identity, identity_changeset(auth, account))
    |> Ecto.Multi.run(:email, fn _ -> {:ok, email} end)
  end

  def insert_email_related_to(identity, auth) do
    %{account: account} = Repo.preload(identity, :account)

    Ecto.Multi.new
    |> Ecto.Multi.run(:account, fn _ ->
      update_empty_account_info(account, auth)
    end)
    |> Ecto.Multi.insert(:email, email_changeset(auth, account))
    |> Ecto.Multi.run(:identity, fn _ -> {:ok, identity} end)
  end

  def update_all(email, identity, auth) do
    %{account: account} = Repo.preload(identity, :account)

    Ecto.Multi.new
    |> Ecto.Multi.run(:account, fn _ ->
      update_empty_account_info(account, auth)
    end)
    |> Ecto.Multi.run(:email, fn _ -> {:ok, email} end)
    |> Ecto.Multi.run(:identity, fn _ -> {:ok, identity} end)
  end

  def merge_and_update_all(email, identity, auth) do
    # NOTE: the old_account is considered the one that should live

    %{account: old_account} = Repo.preload(email, :account)
    %{account: new_account} = Repo.preload(identity, :account)

    Ecto.Multi.new
    |> Ecto.Multi.run(:email, fn _ -> {:ok, email} end)
    |> Ecto.Multi.run(:identity, fn _ ->
      with {:ok, _} <- move_identities_from_account_to_account(new_account.id, old_account.id) do
        {:ok, identity}
      end
    end)
    |> Ecto.Multi.run(:account, fn _ ->
      with {:ok, _} <- Repo.delete(new_account) do
        update_empty_account_info(old_account, auth)
      end
    end)
  end

  defp move_identities_from_account_to_account(from_account_id, to_account_id) do
    case from(i in Identity, where: i.account_id == ^from_account_id)
         |> Repo.update_all(set: [account_id: to_account_id]) do
      {num, _} -> {:ok, num}
      other -> other
    end
  end

  defp update_empty_account_info(account, auth) do
    existing = %{
      name: account.name,
      preferred_username: account.preferred_username,
      avatar_url: account.avatar_url,
      timezone: account.timezone
    }

    possible = extract_account_params(auth)

    intended = Map.merge(existing, possible, fn _key, existing_value, possible_value ->
      case {existing_value, possible_value} do
        {nil, new_value} when not is_nil(new_value) -> new_value
        _ -> existing_value
      end
    end)

    Account.changeset(account, intended)
    |> Repo.update()
  end

  def find_email(%Ueberauth.Auth{} = auth),
    do: find_email(auth.info.email)

  def find_email(address) when is_binary(address) do
    address = Email.format(address)

    from(e in Email,
         where: e.address == ^address,
         lock: "FOR UPDATE")
         |> Repo.one()
  end

  def email_changeset(auth, account) do
    extract_email_params(auth)
    |> Email.changeset(account: account)
  end

  def extract_email_params(auth) do
    %{
      address: auth.info.email
    }
  end

  def find_identity(%Ueberauth.Auth{provider: provider, uid: uid}),
    do: find_identity(to_string(provider), to_string(uid))

  def find_identity(provider, uid) do
    from(i in Identity,
         where: i.provider == ^provider,
         where: i.uid == ^uid,
         lock: "FOR UPDATE")
         |> Repo.one()
  end

  def identity_changeset(auth, account) do
    extract_identity_params(auth)
    |> Identity.changeset(account: account)
  end

  def extract_identity_params(auth) do
    %{
      provider: to_string(auth.provider),
      uid: to_string(auth.uid),
      access_token: auth.credentials.token,
      access_token_expires_at: parse_datetime(auth.credentials.expires_at),
      refresh_token: auth.credentials.refresh_token,
      scope: scopes(auth.credentials.scopes),
      raw: Map.from_struct(auth)
    }
  end

  defp parse_datetime(dt) when is_integer(dt), do: Timex.from_unix(dt)
  defp parse_datetime(dt), do: dt

  defp scopes(string) when is_binary(string), do: string
  defp scopes(list) when is_list(list), do: Enum.join(list, " ")

  def account_changeset(auth) do
    extract_account_params(auth)
    |> Account.changeset()
  end

  def extract_account_params(%Ueberauth.Auth{} = auth) do
    %{
      name: auth.info.name,
      preferred_username: auth.info.nickname,
      avatar_url: nil,
      timezone: nil
    }
  end
end

