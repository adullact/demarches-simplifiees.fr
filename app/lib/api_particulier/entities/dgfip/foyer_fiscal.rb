# frozen_string_literal: true

module APIParticulier
  module Entities
    module DGFIP
      class FoyerFiscal
        def initialize(**kwargs)
          attrs = kwargs.symbolize_keys
          @annee = attrs[:annee]
          @adresse = attrs[:adresse]
        end

        attr_reader :adresse

        def annee
          @annee.to_i
        end
      end
    end
  end
end
