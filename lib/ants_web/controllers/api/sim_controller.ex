require IEx

defmodule AntsWeb.Api.SimController do
  use AntsWeb, :controller

  alias AntsWeb.Api.FallbackController
  alias Ants.Simulations
  alias Ants.Simulations.SimId

  action_fallback(FallbackController)

  @spec index(Plug.Conn.t(), any) :: Plug.Conn.t()
  def index(conn, _params) do
    conn
    |> render("index.json", [])
  end

  def create(conn, params) do
    count = params["count"] || 10

    with {:ok, sim_id} <- Simulations.start(count || 10),
         world <- Simulations.get(sim_id) do
      conn
      |> put_status(:created)
      |> render("show.json", sim_id: sim_id, world: world)
    end
  end

  def show(conn, %{"id" => id}) do
    with {sim_id, ""} <- Integer.parse(id),
         true <- SimId.exists?(sim_id),
         world <- Simulations.get(sim_id) do
      conn
      |> render("show.json", sim_id: sim_id, world: world)
    else
      _ ->
        conn
        |> put_status(:not_found)
        |> render(AntsWeb.ErrorView, :"404")
    end
  end

  def turn(conn, %{"id" => id}) do
    with {sim_id, ""} <- Integer.parse(id),
         true <- SimId.exists?(sim_id),
         world <- Simulations.turn(sim_id) do
      conn
      |> render("show.json", sim_id: sim_id, world: world)
    else
      _ ->
        conn
        |> put_status(:not_found)
        |> render(AntsWeb.ErrorView, :"404")
    end
  end
end