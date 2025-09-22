# Development documentation

## Setting up a local instance

The [README.md](README.md) file is the basis for setting up a local instance.

## Contributing

See:
- [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines about the contribution process (in french),
- [Contributions/Pratiques-de-dev.md](doc/Contributions/Pratiques-de-dev.md) for coding good practises and style elements (in french).

## Re-generating `database_models.pdf`

The database models document is generated using the `rails-erd` gem.

To update the generated PDF file:

1. Install `graphviz` (e.g. `brew install graphviz`)
2. Run `bin/rake erd`
