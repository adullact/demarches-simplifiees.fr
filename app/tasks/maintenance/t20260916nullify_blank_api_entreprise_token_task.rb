# frozen_string_literal: true

module Maintenance
  class T20260916nullifyBlankAPIEntrepriseTokenTask < MaintenanceTasks::Task
    # From 2020-04 to 2020-10 the jetons form saved the field as submitted, an
    # empty one included, and `validates_associated` still accepts a blank
    # token. Those procedures carry '' where nil means "no token of its own",
    # and every reader has to guard against both (`[nil, '']`). Leave nil only.

    include RunnableOnDeployConcern

    run_on_first_deploy

    def collection
      Procedure.with_discarded.where(api_entreprise_token: '')
    end

    def process(procedure)
      # No callback, no timestamp: nothing changes for the administrateur.
      procedure.update_column(:api_entreprise_token, nil)
    end
  end
end
