defmodule Neurony.Repo do
  use Ecto.Repo,
    otp_app: :neurony,
    adapter: Ecto.Adapters.Postgres
end
