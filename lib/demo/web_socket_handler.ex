defmodule Demo.WebSocketHandler do
  @behaviour :cowboy_websocket

  def init(req, opts) do
    {:cowboy_websocket, req, opts}
  end

  def terminate(_reason, _req, _opts) do
    :pg2.leave("mytopic", self())
    :ok
  end

  def websocket_init(opts) do
    :pg2.join("mytopic", self())
    {:ok ,opts}
  end

  def websocket_handle({:text, content}, opts) do
    :pg2.get_members("mytopic")
      |> Enum.each(&(send(&1, {:text, content})))
    {:ok, opts}
  end
  def websocket_handle(_frame, opts) do
    {:ok, opts}
  end

  def websocket_info({:text, content}, opts) do
    {:reply, {:text, content}, opts}
  end
  def websocket_info(_info, opts) do
    {:ok, opts}
  end
end
