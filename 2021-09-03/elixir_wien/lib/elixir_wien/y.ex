defmodule Y do
  use GenServer, restart: :temporary
  require Logger

  ### API ###

  def start, do: DynamicSupervisor.start_child(Sup, __MODULE__)

  def stop do
    GenServer.stop({:global, __MODULE__}, :normal)
  end

  def get_pid do
    GenServer.call({:global, __MODULE__}, :get_pid)
  end

  def start_link(data \\ []) do
    GenServer.start_link(__MODULE__, data, name: {:global, __MODULE__})
  end

  ### SERVER ###

  @impl true
  def init(data) do
    Process.flag(:trap_exit, true)
    {:ok, data}
  end

  @impl true
  def handle_call(:get_pid, _from, state) do
    {:reply, self(), state}
  end

  @impl true
  def handle_info(payload, state) do
    Logger.info("""
    handle_info/2
    server_name: #{inspect(__MODULE__)}
    server_pid: #{inspect(self())}
    payload: #{inspect(payload)}
    ________________________________________
    """)

    {:noreply, state}
  end

  @impl true
  def terminate(reason, _state) do
    Logger.info("""
    terminate/2
    server_name: #{inspect(__MODULE__)}
    server_pid: #{inspect(self())}
    reason: #{inspect(reason)}
    ________________________________________
    """)

    :ok
  end
end
