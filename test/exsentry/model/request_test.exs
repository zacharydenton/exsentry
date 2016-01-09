defmodule FakeConnAdapter do
  def read_req_body(conn, _opts) do
    {:ok, "body", conn}
  end
end

defmodule ExSentry.Model.RequestTest do
  use ExSpec, async: true
  import ExSentry.Model.Request
  doctest ExSentry.Model.Request

  @req_headers [
    {"header1", "value1"},
    {"header2", "value2"},
    {"header1", "value3"}
  ]

  @headers %{"header1" => "value1, value3", "header2" => "value2"}

  @conn %Plug.Conn{
    adapter: {FakeConnAdapter, :hi_mom},
    request_path: "/your/mom",
    method: "POST",
    query_string: "your=mom",
    req_headers: @req_headers,
    remote_ip: {127,0,0,1},
    cookies: %{"mm" => "food"},
  }

  @request %ExSentry.Model.Request{
    url: "/your/mom",
    method: "POST",
    data: "body",
    query_string: "your=mom",
    headers: @headers,
    cookies: %{"mm" => "food"},
    env: %{
      remote_ip: "127.0.0.1"
    }
  }

  describe "from_conn" do
    it "makes a valid ExSentry.Model.Request from conn" do
      assert(@request == from_conn(@conn))
    end
  end

  describe "format_headers" do
    it "merges header values correctly" do
      assert(@headers == format_headers(@req_headers))
    end
  end

  describe "serialization" do
    it "serializes to JSON" do
      assert({:ok, _} = from_conn(@conn) |> Poison.encode)
    end
  end
end

