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
end

