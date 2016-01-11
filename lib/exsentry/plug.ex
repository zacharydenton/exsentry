defmodule ExSentry.Plug do

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

  def handle_errors(conn, %{reason: exception, stack: stack}) do
    req = ExSentry.Model.Request.from_conn(conn)
    st = ExSentry.Model.Stacktrace.from_stacktrace(stack)
    ExSentry.capture_exception(exception, request: req, stacktrace: st)
  end

end

