defmodule Rover do
  use GenServer

  defstruct [:x, :y, :direction, :name]

  @world_width 100
  @world_height 100

  #client API

  def start_link({x,y,direction,name}) do
    #stores name as atom to allow process to be retrieved
    # Start the server and register it locally with name provided
    #so messages can be sent directly to this atom

    # Genserver is like a registry of processes each containing the state
    # defined in the struct (sort of like a template??)
    GenServer.start_link(__MODULE__, {x,y,direction,name}, name: String.to_atom(name))
  end

  @spec get_state(atom | pid | {atom, any} | {:via, atom, any}) :: any
  def get_state(pid) do
    GenServer.call(pid, :get_state)
  end

  def server_exists(server_id) do
    server_atom = String.to_atom(server_id)
    case (GenServer.whereis(server_atom)) do
      nil -> {:not_found, server_atom}
      _ -> {:ok, server_atom}
    end
  end

  @spec go_forward(atom | pid | {atom, any} | {:via, atom, any}) :: any
  def go_forward(pid) do
    GenServer.call(pid, :go_forward)
  end

  def rotate_left(pid) do
    #passes message to the GenServer API to be handled using the atom
    GenServer.cast(pid, :rotate_left)
  end

  #server callbacks

  def init({x,y,d,name}) do
    {:ok, %Rover{x: x, y: y, direction: d, name: name}}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, {:ok, %Rover{x: state.x, y: state.y, direction: state.direction, name: state.name}}, state}
  end

  # this is blocking
  def handle_call(:go_forward, _from, state) do
    # | means merge RHS with LHS
    new_state = case state.direction do
      :N -> %Rover{state | x: state.x, y: Integer.mod(state.y + 1, @world_height)}
      :S -> %Rover{state | x: state.x, y: Integer.mod(state.y - 1, @world_height)}
      :E -> %Rover{state | x: Integer.mod(state.x + 1, @world_width), y: state.y}
      :W -> %Rover{state | x: Integer.mod(state.x - 1, @world_width), y: state.y}
    end
    # response: reply-code, map with response to client, new state to update the server with
    {:reply, {:ok, new_state}, new_state}
  end

  #this is asynchronous
  def handle_cast(:rotate_left, state) do
    new_state =
      case state.direction do
        :N -> %Rover{state | direction: :W}
        :S -> %Rover{state | direction: :E}
        :E -> %Rover{state | direction: :N}
        :W -> %Rover{state | direction: :S}
      end
      {:noreply, new_state}
  end
end
