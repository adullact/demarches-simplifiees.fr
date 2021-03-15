# frozen_string_literal: true

module APIParticulier
  module Entities
    module MESRI
      class Inscription
        def initialize(**kwargs)
          attrs = kwargs.symbolize_keys
          @date_de_debut_d_inscription = attrs[:dateDebutInscription]
          @date_de_fin_d_inscription = attrs[:dateFinInscription]
          @statut = attrs[:statut]
          @regime = attrs[:regime]
          @code_commune = attrs[:codeCommune]
          @etablissement = attrs[:etablissement]
        end

        attr_reader :code_commune

        def date_de_debut_d_inscription
          DateTime.parse(@date_de_debut_d_inscription)
        rescue Date::Error
          nil
        end

        def date_de_fin_d_inscription
          DateTime.parse(@date_de_fin_d_inscription)
        rescue Date::Error
          nil
        end

        def statut
          APIParticulier::Types::StatutEtudiant[@statut]
        rescue ArgumentError
          nil
        end

        def regime
          APIParticulier::Types::RegimeEtudiant[@regime]
        rescue ArgumentError
          nil
        end

        def etablissement
          Etablissement.new(**@etablissement)
        end
      end
    end
  end
end
