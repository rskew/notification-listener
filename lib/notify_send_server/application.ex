defmodule NotifySendServer.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {NotifySendServer.Server, 2001}
    ]

    opts = [strategy: :one_for_one, name: NotifySendServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
