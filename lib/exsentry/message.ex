defmodule ExSentry.Message do

  @doc ~S"""
  Returns an X-Sentry-Auth header based on the given ExSentry
  `version`, `key`, and `secret` (required) and unix `timestamp`
  (optional, defaults to now).
  """
  def get_auth_header(%{version: version, key: key, secret: secret}=args) do
    "X-Sentry-Auth: Sentry sentry_version=7, " <>
    "sentry_client=\"ExSentry/#{version}\", " <>
    "sentry_timestamp=#{args[:timestamp] || unixtime}, " <>
    "sentry_key=#{key}, " <>
    "sentry_secret=#{secret}"
  end

  defp unixtime do
    {mega, sec, _microsec} = :os.timestamp
    mega * 1000000 + sec
  end


  @doc ~S"""
  Given the output of `System.stacktrace`, returns a list of JSON-
  compatible maps in Sentry's `stacktrace` format, oldest to newest.
  """
  def format_stacktrace(stacktrace) do
    stacktrace
    |> Enum.reverse
    |> Enum.map(&format_stacktrace_entry(&1))
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
      file && line -> %{filename: file, lineno: line}
      file -> %{filename: file}
      line -> %{lineno: line}
      true -> %{}
    end
  end


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
    culprit = opts[:culprit]
    hostname = opts[:hostname]
    tags = opts[:tags]
    extra = opts[:extra]

    %{
      event_id: event_id,
      message: message,
      timestamp: timestamp,
      level: level,
      logger: logger,
      platform: "other",   ## no love for Elixir yet

      culprit: culprit,
      server_name: hostname,
      release: versions[:exsentry],
      tags: tags,
      modules: ExSentry.Utils.versions,
      extra: extra
    }
  end

  def merge_tags(global_tags, tags) do
    (Map.to_list(global_tags) ++ Map.to_list(tags))
    |> Enum.map(fn ({k, v}) -> [k, v] end)
  end

end

