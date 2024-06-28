defmodule NotifySendServer do
  def notify(summary, body, critical) do
    IO.inspect([summary, body, critical])
    color = if critical do
      "string:bgcolor:#f00b"
    else
      "string:bgcolor:#0000"
    end
    base_args = ["-u", "critical", "-h", color, summary]
    args = if body != nil do
      base_args ++ [body]
    else
      base_args
    end
    IO.inspect(body)
    IO.inspect(body != nil)
    IO.inspect(args)
    System.cmd("notify-send", args)
  end

  def notify(summary, body) do
    notify(summary, body, false)
  end

  def notify(summary) do
    notify(summary, nil, false)
  end
end
