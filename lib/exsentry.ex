defmodule ExSentry do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      # worker(Exsentry.Worker, [arg1, arg2, arg3]),
      worker(ExSentry.Server, [[name: :exsentry]])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExSentry.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def capture_exception(exception, attrs \\ %{}) do
    trace = System.stacktrace |> Enum.drop(1)
    GenServer.cast(:exsentry, {:capture_exception, exception, trace, attrs})
  end

  def capture_message(message, attrs \\ %{}) do
    GenServer.cast(:exsentry, {:capture_message, message, attrs})
  end

end

