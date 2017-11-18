defmodule Server do
  def start() do
    spawn(fn -> loop() end)
  end

  def send_msg(server, msg) do
    send(server, {self(), msg})

    receive do
      {:response, msg} -> msg
    end
  end

  defp loop() do
    receive do
      {caller, msg} ->
        :timer.sleep(1000)
        send(caller, {:response, msg})
    end

    loop()
  end
end
