# Background jobs

Active Job runs on Solid Queue (`config.active_job.queue_adapter = :solid_queue` in
`config/environments/production.rb`), with the supervisor running inside Puma in production via
`plugin :solid_queue if ENV["SOLID_QUEUE_IN_PUMA"]` in `config/puma.rb`.

## Single database, not Solid Queue's default multi-database setup

Rails 8's `solid_queue:install` generator assumes a split database setup — it sets
`config.solid_queue.connects_to = { database: { writing: :queue } }` and writes a separate
`db/queue_schema.rb`, meant to be loaded against a `queue:` entry in `config/database.yml`. This
app only has one flat database per environment (see `config/database.yml`), so that generator
output doesn't apply as-is.

Solid Queue's tables (`solid_queue_jobs`, `solid_queue_processes`, etc.) are instead created by a
plain migration (`db/migrate/..._create_solid_queue_tables.rb`, copied from the generator's
`db/queue_schema.rb` template) in the same database as everything else, and
`config.solid_queue.connects_to` is intentionally *not* set, so Solid Queue's models just use the
default connection. `config/queue.yml` (worker/dispatcher config), `config/recurring.yml`
(scheduled jobs), and `bin/jobs` (the Solid Queue CLI entrypoint) are unrelated to the
database split and are used normally.

Forgetting this migration is exactly what caused a production crash loop: the Puma plugin's
supervisor tried to register itself in `solid_queue_processes`, which didn't exist, Puma noticed
the supervisor had died, and shut itself down -- repeating on every boot.
