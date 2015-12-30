defmodule ExSentry.Utils do
  @doc ~S"""
  Returns the string-formatted version of the given app.
  """
  def version(app \\ :exsentry) do
    Application.loaded_applications
    |> Enum.filter(&(elem(&1, 0) == app))
    |> List.first
    |> elem(2)
    |> to_string
  end

  @doc ~S"""
  Returns a map of {app: version} pairs.
  """
  def versions do
    Application.loaded_applications
    |> Enum.reduce({}, fn ({app, _desc, ver}, acc) ->
         Map.put(acc, app, to_string(ver))
       end)
  end
end

