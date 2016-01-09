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
    request = opts[:request]

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
      extra: extra,
      request: request
    }
  end

  @doc ~S"""
  Merges two maps of tags, returning a JSON-compatible structure like
  [ [tag1, value1], [tag2, value2], ... ].  Allows duplicates.

      iex> t1 = %{a: 1, b: 2}
      iex> t2 = %{a: 3}
      iex> ExSentry.Message.merge_tags(t1, t2)
      [ [:a, 1], [:b, 2], [:a, 3] ]
  """
  def merge_tags(global_tags, tags) do
    (Map.to_list(global_tags) ++ Map.to_list(tags))
    |> Enum.map(fn ({k, v}) -> [k, v] end)
  end

end

