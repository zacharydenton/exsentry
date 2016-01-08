defmodule ExSentry.Message do

  @doc ~S"""
  Returns an X-Sentry-Auth header value based on the given ExSentry
  `version`, `key`, and `secret` (required) and unix `timestamp`
  (optional, defaults to now).
  """
  def get_auth_header_value(%{version: version, key: key, secret: secret}=args) do
    ts = Map.get(args, :timestamp) || unixtime
    "Sentry sentry_version=7, " <>
    "sentry_client=\"ExSentry/#{version}\", " <>
    "sentry_timestamp=#{ts}, " <>
    "sentry_key=#{key}, " <>
    "sentry_secret=#{secret}"
  end

  defp unixtime do
    {mega, sec, _microsec} = :os.timestamp
    mega * 1000000 + sec
  end


  @doc ~S"""
  Given the output of `System.stacktrace`, returns a JSON- compatible
  structure in Sentry's `stacktrace` format, oldest to newest.
  """
  def format_stacktrace(stacktrace) do
    %{frames: stacktrace |> Enum.map(&format_stacktrace_entry(&1))}
  end

  defp format_stacktrace_entry(entry) do
    case entry do
      {module, fname, arity, file_and_line} ->
        arity = if is_list(arity), do: Enum.count(arity), else: arity
        Map.merge(file_and_line_map(file_and_line), %{
          function: "#{fname}/#{arity}",
          module: module,
        })
    end
  end

  defp file_and_line_map(file_and_line_dict) do
    file = file_and_line_dict[:file]
    line = file_and_line_dict[:line]
    cond do
      file && line -> %{filename: to_string(file), lineno: line}
      file -> %{filename: to_string(file)}
      line -> %{lineno: line}
      true -> %{}
    end
  end


  @doc ~S"""
  Given a list of {headername, value} tuples, returns a map of
  %{headername => merged_values} pairs.
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


  @doc ~S"""
  Returns a JSON-compatible body for Sentry HTTP requests.
  """
  def basic_payload(opts \\ []) do
    versions = ExSentry.Utils.versions
    event_id = UUID.uuid4() |> String.replace("-", "")
    timestamp = Timex.Date.local
                |> Timex.DateFormat.format("{ISOz}")
                |> elem(1)
                |> String.replace(~r"\.\d{3}Z$", "")

    message = opts[:message] |> String.slice(0..999)
    level = opts[:level] || :error
    logger = opts[:logger] || "ExSentry #{versions[:exsentry]}"
    hostname = opts[:hostname] || :inet.gethostname |> elem(1) |> to_string
    stacktrace = opts[:stacktrace]
    culprit = opts[:culprit]
    hostname = opts[:hostname]
    tags = opts[:tags]
    extra = opts[:extra]

    %{
      event_id: event_id,
      platform: "other",   ## no love for Elixir yet
      release: versions[:exsentry],
      modules: versions,
      timestamp: timestamp,

      message: message,
      level: level,
      logger: logger,
      hostname: hostname,
      stacktrace: stacktrace,
      culprit: culprit,
      server_name: hostname,
      tags: tags,
      extra: extra
    }
  end

  @doc ~S"""
  Merges two maps of tags, returning a JSON-compatible structure like
  [ [tag1, value1], [tag2, value2], ... ].  Allows duplicates.
  """
  def merge_tags(global_tags, tags) do
    (Map.to_list(global_tags) ++ Map.to_list(tags))
    |> Enum.map(fn ({k, v}) -> [k, v] end)
  end

end

