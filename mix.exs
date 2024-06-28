defmodule NotifySendServer.MixProject do
  use Mix.Project

  def project do
    [
      app: :notify_send_server,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :runtime_tools],
      mod: {NotifySendServer.Application, []}
    ]
  end

  defp deps do
    [
      {:json, "~> 1.4"},
    ]
  end
end
