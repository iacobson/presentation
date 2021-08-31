defmodule ElixirWien.Application do
  use Application

  def start(_type, _args) do
    connect_nodes()

    children = [
      Sup
    ]

    opts = [strategy: :one_for_one, name: ElixirWien.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def connect_nodes() do
    nodes()
    |> Enum.each(&Node.connect/1)
  end

  defp nodes do
    [:"alpha@127.0.0.1", :"beta@127.0.0.1"]
  end
end
