defmodule Checker.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Checker.GmailAuth,
      Supervisor.child_spec({Checker.SiteChecker, :amazon}, id: :amazon),
      Supervisor.child_spec({Checker.SiteChecker, :walmart}, id: :walmart),
      Supervisor.child_spec({Checker.SiteChecker, :bestbuy}, id: :bestbuy),
      Supervisor.child_spec({Checker.SiteChecker, :target}, id: :target),
      Supervisor.child_spec({Checker.SiteChecker, :gamestop}, id: :gamestop)
      # Supervisor.child_spec({Checker.SiteChecker, :smiths}, id: :smiths)
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Checker.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
