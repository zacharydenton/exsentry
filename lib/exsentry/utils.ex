defmodule ExSentry.Utils do
  def version do
    Application.loaded_applications
    |> Enum.filter(&(elem(&1, 0) == :exsentry))
    |> List.first
    |> elem(2)
    |> to_string
  end
end

