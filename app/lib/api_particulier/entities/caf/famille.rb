# frozen_string_literal: true

module APIParticulier
  module Entities
    module CAF
      class Famille
        def initialize(**kwargs)
          attrs = kwargs.symbolize_keys
          @allocataires = attrs[:allocataires]
          @enfants = attrs[:enfants]
          @adresse = attrs[:adresse]
          @quotient_familial = attrs[:quotientFamilial]
          @annee = attrs[:annee]
          @mois = attrs[:mois]
        end

        def allocataires
          Array(@allocataires).map { |kwargs| Personne.new(**Hash(kwargs)) }
        end

        def enfants
          Array(@enfants).map { |kwargs| Personne.new(**Hash(kwargs)) }
        end

        def adresse
          PosteAdresse.new(**Hash(@adresse))
        end

        def quotient_familial
          @quotient_familial.to_i
        end

        def annee
          @annee.to_i
        end

        def mois
          @mois.to_i
        end
      end
    end
  end
end
