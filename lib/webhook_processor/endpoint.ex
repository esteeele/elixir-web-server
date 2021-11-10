defmodule WebhookProcessor.Endpoint do
  use Plug.Router

  # ordering of plugs is important
  plug(Plug.Logger)
  plug(:match)
  # uses poison for json conversion
  plug(Plug.Parsers, parsers: [:json], json_decoder: Poison)
  plug(:dispatch)

  get "/ping" do
    send_resp(conn, 200, "alive")
  end

  post "/events" do
    {status, body} =
      case conn.body_params do
        %{"events" => events} -> {200, process_events(events)}
        _ -> {422, missing_events()}
      end

    send_resp(conn, status, body)
  end

  defp process_events(events) when is_list(events) do
    print_events(events)
    productSum = calculateProduct(events)
    Poison.encode!(%{response: productSum})
  end

  defp process_events(_) do
    # If we can't process anything, let them know :)
    Poison.encode!(%{response: "Please Send Some Events!"})
  end

  defp calculateProduct(events) do
    List.foldl(events, 1, fn acc, x -> acc * x end)
  end

  # could be used easily to palm off processing to another processor
  defp print_events([head | tail]) do
    IO.puts(head)
    print_events(tail)
  end

  #guard for when list is empty
  defp print_events([]) do
  end

  defp missing_events do
    Poison.encode!(%{error: "Expected Payload: { 'events': [...] }"})
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
