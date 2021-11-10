# WebhookProcessor

So despite the name this doesn't actually use any webhooks (yet, might try implementing that next)

Just having a bit of fun/doing some more unfamiliar programming with Elixir/Erlang 

'Usage' 

```elixir
iex -S mix
SendEvents.sendEvents(100) 
```

Will pointlessly send some random data from a HTTP client to a web server

### Rover API 

Can create a 'rover' that moves about with

POST `/rover`
```json
{
	"rover" : {
		"posx" : 1,
		"posy" : 1,
		"name" : "fido"
	}
}
```

Then move it about with 

POST `rover/{name}`
```json
{
	"update" : "get_state|go_forward|turn_left"
}
```

TODO: Error handling Elixir/Erlang style -> i.e. handle errors with pattern matching not in the Java way of worrying about everything that might break

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `webhook_processor` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:webhook_processor, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/webhook_processor](https://hexdocs.pm/webhook_processor).

