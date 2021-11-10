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

  post "/rover" do
    {status, body} =
      case conn.body_params do
        %{"rover" => rover} -> {200, initRover(rover)}
        _ -> {400, Poison.encode!(%{error: "Bad request"})}
      end

    send_resp(conn, status, body)
  end

  post "/rover/:name" do
    IO.puts(conn.params["name"])

    {status, body} =
      case conn.body_params do
        %{"update" => command} -> {200, handleCommand(command, conn.params["name"])}
        _ -> {400, Poison.encode!(%{error: "Bad request"})}
      end

    send_resp(conn, status, Poison.encode!(body))
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

  defp handleCommand(command, name) do
    IO.puts("Handling")
    case command do
      "go_forward" ->
        {:ok, rover} = Rover.go_forward(String.to_atom(name))
        rover

      "turn_left" ->
        Rover.rotate_left(String.to_atom(name))
        "accepted" #async for some reason

      "get_state" ->
        {:ok, rover} = Rover.get_state(String.to_atom(name))
        rover
      _ ->
        "unknown"
    end
  end

  defp initRover(rover) do
    case rover do
      %{"posx" => posx, "posy" => posy, "name" => name} -> createRover(posx, posy, name)
      _ -> {422, Poison.encode!(%{error: "Cannot process rover json"})}
    end
  end

  defp createRover(posx, posy, name) do
    {:ok, pid} = Rover.start_link({posx, posy, :N, name})
    Poison.encode!(%{"status" => "created", "name" => name})
  end

  defp calculateProduct(events) do
    List.foldl(events, 1, fn acc, x -> acc * x end)
  end

  # could be used easily to palm off processing to another processor
  defp print_events([head | tail]) do
    IO.puts(head)
    print_events(tail)
  end

  # guard for when list is empty
  defp print_events([]) do
  end

  defp missing_events do
    Poison.encode!(%{error: "Expected Payload: { 'events': [...] }"})
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
