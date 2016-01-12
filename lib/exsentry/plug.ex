defmodule ExSentry.Plug do
  @moduledoc ~S"""
  ExSentry.Plug is a Plug error handler which can be used to automatically
  intercept and report to Sentry any exceptions encountered by a Plug-based
  web application.

  To use, configure `mix.exs` and `config.exs` as described in README.md,
  then add `use ExSentry.Plug` near the top of your webapp's plug stack,
  for example:

      defmodule MyApp.Router do
        use MyApp.Web, :router
        use ExSentry.Plug

        pipeline :browser do
        ...
  """

  defmacro __using__(_env) do
    quote do
      use Plug.ErrorHandler

      ## Ignore missing Plug and Phoenix routes
      defp handle_errors(_conn, %{reason: %FunctionClauseError{function: :do_match}}) do
        nil
      end
      if :code.is_loaded(Phoenix) do
        defp handle_errors(_conn, %{reason: %Phoenix.Router.NoRouteError{}}) do
          nil
        end
      end

      defp handle_errors(conn, %{reason: exception, stack: stack}=args) do
        ExSentry.Plug.handle_errors(conn, args)
      end
    end
  end

  @spec handle_errors(%Plug.Conn{}, map) :: :ok
  def handle_errors(conn, %{reason: exception, stack: stack}) do
    req = ExSentry.Model.Request.from_conn(conn)
    st = ExSentry.Model.Stacktrace.from_stacktrace(stack)
    ExSentry.capture_exception(exception, request: req, stacktrace: st)
  end
end

