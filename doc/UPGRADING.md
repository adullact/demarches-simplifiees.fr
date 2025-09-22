# Upgrading to a new release

Theoretically, only deploying each version sequentially is fully supported. This means that to deploy the version N+3, the upgrade plan should be to deploy the version N+1, N+2 and then only N+3, in that order.
On-the-go releases are engineered not to require any downtime. However quaterly releases do require downtime. 

Usually, an upgrade deployment goes like this (in pseudo-code):

```
# Run database schema migrations (e.g. `bin/rails db:migrate`)
# For each server:
  # Stop the server
  # Get the new code (e.g. `git clone git@github.com:betagouv/demarches-simplifiees.fr.git`)
  # Install new dependencies (e.g. `bundle install && bun install`)
  # Restart the app server
# Run data migrations (e.g. `rake after_party:run`)
```

On the main instance, this deployment flow is implemented using [`mina`](https://github.com/mina-deploy/mina), which automatically sshs to the application servers, run the appropriate commands (see `lib/tasks/deploy.rake` and `config/deploy.rb`), and restarts the puma webserver in a way that ensures zero-downtime deployments.
A deploy on multiple application servers is typically done using:
```shell
DOMAINS="web1 web2" BRANCH="main" bin/rake deploy
```

### 6.1 Standard upgrade path

Theoretically, only deploying each version sequentially is fully supported. This means that to deploy the version N+3, the upgrade plan should be to deploy the version N+1, N+2 and then only N+3, in that order.

Release notes for each version are available on [GitHub's Releases page](https://github.com/betagouv/demarches-simplifiees.fr/releases). Since 2022, when a release includes a database schema or data migration is present, this is mentionned in the release notes.

### 6.2 Upgrading several releases at once

Upgrading from several releases at once (like migrating directly from a version N to a version N+3) is theoretically unsupported. This is because database schema migrations and data migrations have to run in the exact order they were created, along the application code as it was when the migration was written.
That said, it is possible to batch the upgrade of several releases at once, _provided that the data migrations run in the correct order_.

The rule of thumb is that _an intermediary upgrade should be done before every database schema migration that follows a data migration_.

_NB: There are some plans to improve this, and contributions are welcome. See https://github.com/betagouv/demarches-simplifiees.fr/issues/6970_
