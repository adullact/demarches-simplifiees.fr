# frozen_string_literal: true

module Maintenance
  class T20241121MigrateCnafDgfipChampsTask < MaintenanceTasks::Task
    # Documentation: cette tâche convertit les champs dépréciés CNAF et DGFIP en champs texte

    include RunnableOnDeployConcern
    include StatementsHelpersConcern

    no_collection

    def process
      TypeDeChamp.where(type_champ: ['cnaf', 'dgfip']).update_all(type_champ: 'text')
      Champ.where(type: ['Champs::CnafChamp', 'Champs::DgfipChamp']).update_all(type: 'Champs::TextChamp')
    end
  end
end
