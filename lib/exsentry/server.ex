defmodule ExSentry.Server do

  defmodule State do
    defstruct dsn: nil,
              key: nil,
              secret: nil,
              project_id: nil,
              version: nil,
              disabled: false
  end

  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, %{}, opts)
  end

  def init(args \\ %{}) do
    dsn = Map.get(args, :dsn) || Application.get_env(:exsentry, :dsn)
    key = Map.get(args, :key) || Application.get_env(:exsentry, :key)
    secret = Map.get(args, :secret) || Application.get_env(:exsentry, :secret)

    cond do
      Mix.env == :test || dsn == "" ->
        {:ok, %State{disabled: true}}
      is_nil(dsn) ->
        raise "Sentry DSN is not set in config.  Add `config " <>
          ":exsentry, dsn: \"your-dsn-here\"` to your config.exs."
      is_nil(key) ->
        raise "Sentry API Key is not set in config.  Add `config " <>
           ":exsentry, key: \"your-key-here\"` to your config.exs."
      is_nil(secret) ->
        raise "Sentry API Secret is not set in config.  Add `config " <>
           ":exsentry, secret: \"your-secret-here\"` to your config.exs."
      true ->
        init(dsn, key, secret)
    end
  end

  defp init(dsn, key, secret) do
    case Fuzzyurl.from_string(dsn) do
      nil ->
        raise "DSN couldn't be parsed"
      fu ->
        project_id = fu.path |> String.split("/") |> List.last
        {:ok, %State{
          dsn: dsn,
          key: key,
          secret: secret,
          project_id: project_id,
          version: ExSentry.Utils.version
        }}
    end
  end

  def handle_cast(_, %State{disabled: true}=state) do
    {:noreply, state}
  end

  def handle_cast({:capture_exception, exception, trace, attrs}, %State{}=state) do
    {:noreply, state}
  end

  def handle_cast({:capture_message, message, attrs}, %State{}=state) do
    {:noreply, state}
  end

end

