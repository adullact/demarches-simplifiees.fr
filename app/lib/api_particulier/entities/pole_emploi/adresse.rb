# frozen_string_literal: true

module APIParticulier
  module Entities
    module PoleEmploi
      class Adresse
        def initialize(**kwargs)
          attrs = kwargs.symbolize_keys
          @code_postal = attrs[:codePostal]
          @insee_commune = attrs[:INSEECommune]
          @localite = attrs[:localite]
          @ligne_voie = attrs[:ligneVoie]
          @ligne_complement_destinataire = attrs[:ligneComplementDestinataire]
          @ligne_complement_d_adresse = attrs[:ligneComplementAdresse]
          @ligne_complement_de_distribution = attrs[:ligneComplementDistribution]
          @ligne_nom_du_detinataire = attrs[:ligneNom]
        end

        attr_reader :code_postal, :insee_commune, :localite, :ligne_voie, :ligne_complement_destinataire,
                    :ligne_complement_d_adresse, :ligne_complement_de_distribution, :ligne_nom_du_detinataire
      end
    end
  end
end
