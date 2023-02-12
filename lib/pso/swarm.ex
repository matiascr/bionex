defmodule Swarm do
  defstruct [:num_ants, :b_up, :b_down, :phi_p, :phi_g, :w]

  @type t :: %__MODULE__{
          num_ants: integer,
          b_up: number,
          b_down: number,
          phi_p: float,
          phi_g: float
        }

  opts = [
    b_up: [type: :float, default: 1.0, doc: "Upper bound"],
    b_down: [type: :float, default: -1.0, doc: "Lower bound"],
    phi_p: [type: :float, default: 1.0, doc: "Cognitive coefficient"],
    phi_g: [type: :float, default: 3.0, doc: "Social coefficient"],
    w: [type: :float, default: 0.5, doc: "Inertia"]
  ]

  @timeout 100_000

  @opts_schema NimbleOptions.new!(opts)

  @spec init(pos_integer(), keyword()) :: __MODULE__.t()
  def init(num_ants, opts \\ []) do
    opts = NimbleOptions.validate!(opts, @opts_schema)
    Kernel.struct!(%__MODULE__{num_ants: num_ants}, opts)
  end

  @spec run(__MODULE__.t(), pos_integer(), fun()) :: any()
  def run(swarm, num_iter \\ 10, fun \\ &Nx.sum/1) do
    best_pos =
      swarm
      |> initialize_particles(fun)
      |> iterate(num_iter, fun)
      |> get_best(fun)

    {best_pos, fun.(best_pos)}
  end

  @spec initialize_particles(__MODULE__.t(), fun()) :: [pid()]
  def initialize_particles(swarm, fun) do
    # Initialize positions
    particles =
      swarm
      |> create(fun)
      |> initialize()

    # Initialize bests
    particles
    |> get_best(fun)
    |> set_best(particles)

    particles
    |> set_vel()

    particles
  end

  @spec create(__MODULE__.t(), fun()) :: [pid()]
  def create(swarm, fun) do
    1..swarm.num_ants
    |> Enum.map(fn _ ->
      GenServer.start_link(
        Particle,
        %Particle{
          swarm: self(),
          b_up: swarm.b_up,
          b_down: swarm.b_down,
          phi_p: swarm.phi_p,
          phi_g: swarm.phi_g,
          w: swarm.w,
          fun: fun
        }
      )
      |> elem(1)
    end)
  end

  def iterate(pids, num_iter, fun) do
    1..num_iter
    |> Enum.each(fn _ ->
      pids
      |> move()
      |> get_best(fun)
      |> set_best(pids)

      pids
      |> set_vel()
    end)

    pids
  end

  # Particle commands
  @spec initialize([pid()]) :: [pid()]
  def initialize(pids), do: async_call(pids, :initialize)

  @spec get_all([pid()]) :: [pid()]
  def get_all(pids), do: async_call(pids, :get)

  @spec get_best([pid()], fun()) :: Nx.Tensor.t()
  def get_best(pids, fun) do
    pids |> async_call(:get_best) |> Enum.min_by(&(fun.(&1) |> Nx.to_number()))
  end

  @spec set_best(Nx.Tensor.t(), [pid()]) :: [pid()]
  def set_best(best, pids) do
    IO.puts("Current best: ")
    IO.inspect(best)
    async_cast(pids, :set_best, best)
  end

  @spec set_vel([pid()]) :: [pid()]
  def set_vel(pids), do: async_call(pids, :set_vel)

  @spec move([pid()]) :: [pid()]
  def move(pids), do: async_call(pids, :move)

  # Call/Cast interfaces -------------------------------------------------------

  @spec async_call([pid()], atom()) :: [pid()]
  def async_call(pids, command) do
    pids
    |> Enum.map(&Task.async(fn -> GenServer.call(&1, command, @timeout) end))
    |> Task.await_many(@timeout)
  end

  @spec async_cast([pid()], atom(), any()) :: [pid()]
  def async_cast(pids, command, content) do
    pids
    |> Enum.map(&Task.async(fn -> GenServer.cast(&1, {command, content}) end))
    |> Task.await_many(@timeout)
  end
end
