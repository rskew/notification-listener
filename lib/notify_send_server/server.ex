defmodule NotifySendServer.Server do
  use GenServer

  def start_link(port) do
    GenServer.start_link(__MODULE__, port, name: __MODULE__)
  end

  def init(port) do
    {:ok, socket} = :gen_udp.open(port, [:binary, active: true])
    IO.puts("Listening on UDP port #{port}")
    {:ok, socket}
  end

  def handle_info({:udp, _socket, _address, _port, data}, socket) do
    IO.puts("Received message: #{String.trim data}")
    case JSON.decode(data) do
      {:ok, [summary, body, critical]} ->
        NotifySendServer.notify(summary, body, critical)
      {:ok, [summary, body]} ->
        NotifySendServer.notify(summary, body)
      _ ->
        NotifySendServer.notify(data)
    end
    {:noreply, socket}
  end

  def handle_info([summary, body, critical], socket) do
    NotifySendServer.notify(summary, body, critical)
    {:noreply, socket}
  end

  def handle_info([summary, body], socket) do
    NotifySendServer.notify(summary, body)
    {:noreply, socket}
  end

  def handle_info(summary, socket) when is_binary(summary) do
    NotifySendServer.notify(summary)
    {:noreply, socket}
  end
end
