ExUnit.start()
Triplex.create("tenant_a")
Triplex.create("tenant_b")
Ecto.Adapters.SQL.Sandbox.mode(MyApp.Repo, :manual)
