defmodule WebhookProcessor do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [

      #https://github.com/emadb/rovex/blob/master/lib/application.ex use this to fix stupid registry issues
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: WebhookProcessor.Endpoint,
        options: [
          port: 4001
        ]
      ),
      Registry.child_spec(
        # multiple processes can be registered under 1 key in the registry
        keys: :duplicate,
        name: Registry.WebhookProcessor
      )
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: WebhookProcessor.Supervisor]
    Supervisor.start_link(children, opts)
  end

end
