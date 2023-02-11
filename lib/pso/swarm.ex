defmodule Swarm do
  defstruct [:num_ants, :b_up, :b_down, :phi_p, :phi_g]

  @type t :: %__MODULE__{
          num_ants: integer,
          b_up: number,
          b_down: number,
          phi_p: float,
          phi_g: float
        }

  opts = [
    b_up: [
      type: :float,
      default: 1.0,
      doc: """
      """
    ],
    b_down: [
      type: :float,
      default: -1.0,
      doc: """
      """
    ],
    phi_p: [
      type: :float,
      default: 0.2,
      doc: """
      """
    ],
    phi_g: [
      type: :float,
      default: 0.2,
      doc: """
      """
    ]
  ]

  @opts_schema NimbleOptions.new!(opts)

  def init(num_ants, opts \\ []) do
    opts = NimbleOptions.validate!(opts, @opts_schema)
    Kernel.struct!(%__MODULE__{num_ants: num_ants}, opts)
  end

  def run(swarm, num_iter \\ 10) do
    initialize_particles(swarm)
  end

  def initialize_particles(swarm) do
    swarm
    |> create()
    |> initialize()
  end

  def create(swarm) do
    1..swarm.num_ants
    |> Enum.map(fn _ ->
      GenServer.start_link(
        Particle,
        %Particle{
          swarm: self(),
          b_up: swarm.b_up,
          b_down: swarm.b_down,
          phi_p: swarm.phi_p,
          phi_g: swarm.phi_g
        }
      )
      |> elem(1)
    end)
  end

  def initialize(pids) do
    pids
    |> Enum.map(&Task.async(fn -> GenServer.call(&1, :initialize) end))
    |> Task.await_many()
  end

  def set_local_best() do
  end

  def set_global_best() do
  end

  def set_velocity() do
  end

  def move() do
  end
end
