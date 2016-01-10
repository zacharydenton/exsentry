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
    |> Enum.reduce(%{}, fn ({app, _desc, ver}, acc) ->
         Map.put(acc, app, to_string(ver))
       end)
  end

  @doc ~S"""
  Given a list of {headername, value} tuples, returns a map of
  %{headername => merged_values} pairs suitable for inclusion in a
  Sentry "Http" object as `headers`.

      iex> headers = [{"header1", "value1"}, {"header2", "value2"}, {"header1", "value3"}]
      iex> headers |> ExSentry.Utils.merge_http_headers
      %{"header1" => "value1, value3", "header2" => "value2"}
  """
  def merge_http_headers(headers) do
    Enum.reduce headers, %{}, fn ({key, value}, acc) ->
      if Map.has_key?(acc, key) do
        oldval = Map.get(acc, key)
        Map.put(acc, key, "#{oldval}, #{value}")
      else
        Map.put(acc, key, value)
      end
    end
  end

  @doc ~S"""
  Merges two maps of tags, returning a JSON-compatible structure like
  [ [tag1, value1], [tag2, value2], ... ].  Allows duplicates.

      iex> t1 = %{a: 1, b: 2}
      iex> t2 = %{a: 3}
      iex> ExSentry.Utils.merge_tags(t1, t2)
      [[:a, 1], [:b, 2], [:a, 3]]
  """
  @spec merge_tags(map, map) :: [[atom: any]]
  def merge_tags(global_tags, tags) do
    (Map.to_list(global_tags) ++ Map.to_list(tags))
    |> Enum.map(fn ({k, v}) -> [k, v] end)
  end


  @spec unixtime :: integer
  def unixtime do
    {mega, sec, _microsec} = :os.timestamp
    mega * 1000000 + sec
  end
end

