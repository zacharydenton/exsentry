defmodule ExSentry.Model.Request do
  @derive [Poison.Encoder]

  defstruct url: nil,
            method: nil,
            data: nil,
            query_string: nil,
            headers: nil,
            cookies: nil,
            env: nil

  @doc ~S"""
  Returns a JSON-compatible map describing the given `conn`, adhering
  to the Sentry "Http" interface.
  """
  def from_conn(conn) do
    {:ok, data, _conn} = Plug.Conn.read_body(conn, length: 8192)
    headers = conn.req_headers |> format_headers
    cookies = conn.cookies || (conn |> Plug.Conn.fetch_cookies).cookies
    %ExSentry.Model.Request{
      url: conn.request_path,
      method: conn.method,
      data: data,
      query_string: conn.query_string,
      headers: headers,
      cookies: cookies,
      env: %{
        remote_ip: conn.remote_ip |> format_ip
      }
    }
  end

  defp format_ip({a, b, c, d}), do: "#{a}.#{b}.#{c}.#{d}"

  @doc ~S"""
  Given a list of {headername, value} tuples, returns a map of
  %{headername => merged_values} pairs suitable for inclusion in a
  Sentry "Http" object as `headers`.
  """
  def format_headers(req_headers) do
    Enum.reduce req_headers, %{}, fn ({key, value}, acc) ->
      if Map.has_key?(acc, key) do
        oldval = Map.get(acc, key)
        Map.put(acc, key, "#{oldval}, #{value}")
      else
        Map.put(acc, key, value)
      end
    end
  end

end
