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

# iex(1)> {:ok, pid} = Rover.start_link({1,1,:N,"hello"})
# {:ok, #PID<0.160.0>}
# iex(2)> Rover.go_forward(pid)
# {:ok, %Rover{direction: :N, name: "hello", x: 1, y: 2}}
# iex(3)> Rover.get_state(pid)
# {:ok, {1, 2, :N, "hello"}}
# iex(4)> Rover.rotate_left(pid)
# :ok
# iex(5)> Rover.go_forward(pid)
# {:ok, %Rover{direction: :W, name: "hello", x: 0, y: 2}}
# iex(6)> Rover.get_state(pid)
# {:ok, {0, 2, :W, "hello"}}
# iex(7)> {:ok, rover_2_pid} = Rover.start_link({1,1,:N,"friend"})
# {:ok, #PID<0.167.0>}
# iex(8)> Rover.g
# get_state/1     go_forward/1
# iex(8)> Rover.go_forward(rover_2_pid)
# {:ok, %Rover{direction: :N, name: "friend", x: 1, y: 2}}
# iex(9)> Rover.get_state(rover_2_pid)
# {:ok, {1, 2, :N, "friend"}}
# iex(10)> Rover.get_state(:friend) #can be accessible by atom as well
# {:ok, {1, 2, :N, "friend"}}
