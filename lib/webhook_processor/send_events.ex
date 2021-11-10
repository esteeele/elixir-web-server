defmodule SendEvents do
  def sendEvents(numberOfEvents) do
    index = numberOfEvents
    sendEvent(index)
  end

  defp sendEvent(index) when index > 0 do
    url = "http://localhost:4001/events"
    body = Poison.encode!(%{"events" => makeRandomList([], Enum.random(1..100))})
    IO.puts(body)
    response = HTTPoison.post(url, body, [{"Content-Type", "application/json"}])
    case response do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} -> IO.puts(body)
      {:error, %HTTPoison.Error{reason: reason}} -> IO.inspect(reason)
    end

    sendEvent(index-1)
  end

  defp sendEvent(_index) do
    IO.puts("sent all events")
  end

  defp makeRandomList(list, size) when size > 0 do
    randomNumber = Enum.random(1..100000)
    makeRandomList(list ++ List.wrap(randomNumber), size - 1)
  end

  defp makeRandomList(list, 0) do
    list
  end
end
