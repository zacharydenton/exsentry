defmodule ExSentry.Utils do
  def version do
    Application.loaded_applications
    |> Enum.filter(&(elem(&1, 0) == :exsentry))
    |> List.first
    |> elem(2)
    |> to_string
  end

  def versions do
    Application.loaded_applications
    |> Enum.reduce({}, fn ({app, _desc, ver}, acc) ->
         Map.put(acc, app, to_string(ver))
       end)
    end
  end
end

