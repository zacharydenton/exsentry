defmodule ExSentry.SenderTest do
  use ExSpec, async: false
  import Mock
  import ExSentry.Sender, only: [send_request: 4]

  setup do
    {:ok, pid} = GenServer.start_link(ExSentry.Sender,
      %{testing: true, logging: false, delay: 1})
    {:ok, sender: pid}
  end

  @response_1xx %{status_code: 100, headers: []}
  @response_2xx %{status_code: 200, headers: []}
  @response_3xx %{status_code: 301, headers: ["Location": "https://example.com"]}
  @response_4xx %{status_code: 400, headers: ["X-Sentry-Error": "omg"]}
  @response_5xx %{status_code: 503, headers: ["X-Sentry-Error": "lol"]}

  describe "send_request/4" do
    it "handles 2xx", %{sender: sender} do
      with_mock HTTPotion, [
        post: fn (_url, _opts) -> @response_2xx end
      ] do
        send_request(sender, "", [], "")
        assert(:success == GenServer.call(sender, :state)[:status])
      end
    end

    it "handles 3xx", %{sender: sender} do
      with_mock HTTPotion, [
        post: fn (_url, _opts) -> @response_3xx end
      ] do
        send_request(sender, "", [], "")
        assert(:max_retries == GenServer.call(sender, :state)[:status])
      end
    end

    it "handles 4xx", %{sender: sender} do
      with_mock HTTPotion, [
        post: fn (_url, _opts) -> @response_4xx end
      ] do
        send_request(sender, "", [], "")
        assert(:client_error == GenServer.call(sender, :state)[:status])
      end
    end

    it "handles 5xx", %{sender: sender} do
      with_mock HTTPotion, [
        post: fn (_url, _opts) -> @response_5xx end
      ] do
        send_request(sender, "", [], "")
        assert(:max_retries == GenServer.call(sender, :state)[:status])
      end
    end

    it "handles other statuses", %{sender: sender} do
      with_mock HTTPotion, [
        post: fn (_url, _opts) -> @response_1xx end
      ] do
        send_request(sender, "", [], "")
        assert(:unhandled_status == GenServer.call(sender, :state)[:status])
      end
    end

  end
end
