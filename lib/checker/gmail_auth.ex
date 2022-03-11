defmodule Checker.GmailAuth do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(_) do
    config = Application.get_env(:checker, __MODULE__)

    state = %{
      client_id: Keyword.get(config, :client_id),
      client_secret: Keyword.get(config, :client_secret),
      refresh_token: Keyword.get(config, :refresh_token),
      access_token: nil
    }

    Process.send_after(self(), :refresh, :timer.seconds(5))
    {:ok, state}
  end

  @impl true
  def handle_call(:fetch_token, _, %{access_token: access_token} = state) do
    {:reply, access_token, state}
  end

  def get_access_token() do
    GenServer.call(__MODULE__, :fetch_token)
  end

  @impl true
  def handle_info(:refresh, state) do
    Process.send_after(self(), :refresh, :timer.minutes(45))

    case refresh_access_token(state) do
      {:ok, access_token} ->
        {:noreply, %{state | access_token: access_token}}

      {:error, error} ->
        Checker.Notify.error("GmailAuth Busted: #{inspect(error)}")
        {:noreply, state}
    end
  end

  def refresh_access_token(state) do
    HTTPoison.post!(
      "https://oauth2.googleapis.com/token",
      Jason.encode!(%{
        client_id: state.client_id,
        client_secret: state.client_secret,
        grant_type: "refresh_token",
        refresh_token: state.refresh_token
      }),
      "content-type": "application/json"
    )
    |> Map.get(:body)
    |> Jason.decode!()
    |> case do
      %{"access_token" => token} -> {:ok, token}
      %{"error" => _} = error -> {:error, error}
      obj -> {:error, obj}
    end
  end

  # Initial Token Setup

  def oauth_client_url() do
    params = %{
      client_id: config(:client_id),
      redirect_uri: "http://localhost:4000",
      response_type: "code",
      access_type: "offline",
      scope: "https://mail.google.com/",
      state: id()
    }

    "https://accounts.google.com/o/oauth2/v2/auth"
    |> URI.parse()
    |> Map.put(:query, URI.encode_query(params))
    |> URI.to_string()
  end

  def exchange_token(url) do
    %{"code" => code} =
      url
      |> URI.parse()
      |> Map.get(:query)
      |> URI.decode_query()

    params = %{
      code: code,
      client_id: config(:client_id),
      client_secret: config(:client_secret),
      redirect_uri: "http://localhost:4000",
      grant_type: "authorization_code"
    }

    token_url =
      "https://oauth2.googleapis.com/token"
      |> URI.parse()
      |> Map.put(:query, URI.encode_query(params))
      |> URI.to_string()

    case HTTPoison.post!(token_url, "", [{"Accept", "application/json"}]) do
      %HTTPoison.Response{status_code: 200, body: body} -> Jason.decode!(body)
      resp -> resp
    end
  end

  defp config(key), do: Application.get_env(:checker, __MODULE__) |> Keyword.get(key)

  @max_num String.to_integer("ZZZZZZZZZZ", 36)
  defp id(), do: @max_num |> :rand.uniform() |> Integer.to_string(36)
end
