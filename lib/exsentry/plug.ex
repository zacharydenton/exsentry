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

      defp handle_errors(conn, %{reason: exception, stack: stack}) do
        request = ExSentry.Message.format_request(conn)

      end
    end
  end



end

