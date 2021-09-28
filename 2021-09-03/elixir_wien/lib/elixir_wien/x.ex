defmodule X do
  use GenServer, restart: :temporary
  require Logger

  ### API ###

  def start, do: DynamicSupervisor.start_child(Sup, __MODULE__)

  def stop do
    GenServer.stop({:global, __MODULE__}, :normal)
  end

  def get_pid do
    GenServer.whereis({:global, __MODULE__})
  end

  def start_link(data \\ []) do
    GenServer.start_link(__MODULE__, data, name: {:global, __MODULE__})
  end

  ### TEST ###

  def test_alive do
    GenServer.call({:global, __MODULE__}, :test_alive)
  end

  def test_exit do
    GenServer.call({:global, __MODULE__}, :test_exit)
  end

  def test_link do
    GenServer.call({:global, __MODULE__}, :test_link)
  end

  def test_monitor do
    GenServer.call({:global, __MODULE__}, :test_monitor)
  end

  def test_register do
    GenServer.call({:global, __MODULE__}, :test_register)
  end

  def test_send do
    GenServer.call({:global, __MODULE__}, :test_send)
  end

  def test_send_after do
    GenServer.call({:global, __MODULE__}, :test_send_after)
  end

  ### SERVER ###

  @impl true
  def init(data) do
    Process.flag(:trap_exit, true)
    {:ok, data}
  end

  @impl true
  def handle_call(:test_alive, _from, state) do
    response = Y.get_pid() |> Process.alive?()
    {:reply, response, state}
  end

  def handle_call(:test_exit, _from, state) do
    response = Y.get_pid() |> Process.exit(:unexpected_reason)
    {:reply, response, state}
  end

  def handle_call(:test_link, _from, state) do
    Y.get_pid() |> Process.link()
    {:stop, {:shutdown, :testing_link}, :ok, state}
  end

  def handle_call(:test_monitor, _from, state) do
    ref = Y.get_pid() |> Process.monitor()
    Y.stop()
    {:reply, %{reference: ref}, state}
  end

  def handle_call(:test_register, _from, state) do
    Y.get_pid() |> Process.register(:r2d2)
    send(:r2d2, :bip_bip)
    {:reply, :ok, state}
  end

  def handle_call(:test_send, _from, state) do
    Y.get_pid() |> Process.send(:greetings, [])
    {:reply, :ok, state}
  end

  def handle_call(:test_send_after, _from, state) do
    Y.get_pid() |> Process.send_after(:christmas_greetings, 1000)
    {:reply, :ok, state}
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
