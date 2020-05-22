# Pow Demo App

Start the first node with:

```bash
elixir --name a@127.0.0.1 -S mix phx.server
```

Then start the second node with:

```bash
PORT=4001 elixir --name b@127.0.0.1 -S mix phx.server
```

Sign in at http://localhost:4000/session/new and update registration at http://localhost:4001/registration/edit.

To create large mnesia table in IEX:

```elixir
> length = 1_000_000
> Enum.each(1..100, & PowPersistentSession.Store.PersistentSessionCache.put([backend: Pow.Store.Backend.MnesiaCache, ttl: :timer.hours(24) * 30], &1, :crypto.strong_rand_bytes(length) |> Base.url_encode64 |> binary_part(0, length)))
```

## Demo branches

- [Full Pow demo](https://github.com/pow-auth/pow_demo/tree/full-app) [(diff)](https://github.com/pow-auth/pow_demo/compare/all-extensions..full-app)

  *A fully working demo app based off the `all-extensions` branch. Content of sent mails can be found in logs.*

## Base branches

These branches only consists of the absolute minimum configuration.

- [Basic Pow Phoenix setup](https://github.com/pow-auth/pow_demo/) [(diff)](https://github.com/pow-auth/pow_demo/compare/phoenix-base..master)

  *The minimum setup needed with Pow on a Phoenix app.*

- [All extensions](https://github.com/pow-auth/pow_demo/tree/all-extensions) [(diff)](https://github.com/pow-auth/pow_demo/compare/master..all-extensions)

  *The base Pow setup with all Pow extensions enabled. Content of sent mails can be found in logs.*

### Pow guides

- [User roles](https://github.com/pow-auth/pow_demo/tree/user-roles) [(diff)](https://github.com/pow-auth/pow_demo/compare/master..user-roles)
  
  *The base Pow setup with [user roles guide](https://hexdocs.pm/pow/1.0.20/user_roles.html).*

- [Lock users](https://github.com/pow-auth/pow_demo/tree/lock-users) [(diff)](https://github.com/pow-auth/pow_demo/compare/master..lock-users)
  
  *The base Pow setup with [lock users guide](https://hexdocs.pm/pow/1.0.20/lock_users.html).*

- [Lock users with PowResetPassword](https://github.com/pow-auth/pow_demo/tree/lock-users-with-reset-password) [(diff)](https://github.com/pow-auth/pow_demo/compare/lock-users..lock-users-with-reset-password)

  *The `lock-users` branch with `PowResetPassword` extension enabled and handled as described in the guide.*

- [Redis Cache Store Backend](https://github.com/pow-auth/pow_demo/tree/redis-cache-store-backend) [(diff)](https://github.com/pow-auth/pow_demo/compare/master..redis-cache-store-backend)

  *The base Pow setup with [Redis cache store backend guide](https://hexdocs.pm/pow/1.0.20/redis_cache_store_backend.html).*

- [Multitenancy with Triplex](https://github.com/pow-auth/pow_demo/tree/multitenancy-triplex) [(diff)](https://github.com/pow-auth/pow_demo/compare/master..multitenancy-triplex)

  *The base Pow setup with [Multitenancy Triplex guide](https://hexdocs.pm/pow/1.0.20/multitenancy.html#triplex).*

- [API](https://github.com/pow-auth/pow_demo/tree/api) [(diff)](https://github.com/pow-auth/pow_demo/compare/master..api)

  *The base Pow setup with [API guide](https://hexdocs.pm/pow/1.0.20/api.html).*

### PowAuth.com guides

- [Password breach validation](https://github.com/pow-auth/pow_demo/tree/powauth.com-password-breach-validation) [(diff)](https://github.com/pow-auth/pow_demo/compare/master..powauth.com-password-breach-validation)

  *The base Pow setup with [Password breach lookup and other password validation rules](https://powauth.com/guides/2019-09-14-password-breach-lookup-and-other-password-validation-rules.html).*

- [Resend e-mail confirmation link](https://github.com/pow-auth/pow_demo/tree/powauth.com-resend-email-confirmation-link) [(diff)](https://github.com/pow-auth/pow_demo/compare/all-extensions..powauth.com-resend-email-confirmation-link)

  *The `all-extensions` branch with [Resend email confirmation link post](https://powauth.com/guides/2020-03-07-resend-email-confirmation-link.html). Content of sent mails can be found in logs.*

## Start the app

To start the Phoenix server:

- Setup the project with `mix setup`
- Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
