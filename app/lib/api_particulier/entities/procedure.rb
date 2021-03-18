# frozen_string_literal: true

module APIParticulier
  module Entities
    class Procedure
      def initialize(procedure)
        @procedure = procedure
      end

      def sources
        {
          dgfip: {
            avis_imposition: dgfip_avis_imposition,
            foyer_fiscal: dgfip_foyer_fiscal
          },
          caf: {
            allocataires: caf_allocataires,
            enfants: caf_enfants,
            adresse: caf_adresse,
            quotient_familial: caf_quotient_familial
          },
          pole_emploi: {
            situation: pole_emploi_situation
          },
          mesri: {
            statut_etudiant: mesri_statut_etudiant
          }
        }.with_indifferent_access
      end

      def dgfip_avis_imposition
        return {} unless @procedure.api_particulier_scope?("dgfip_avis_imposition")

        APIParticulier::Entities::DGFIP::AvisImposition.new.as_json.tap do |avis|
          avis["declarant1"] ||= APIParticulier::Entities::DGFIP::Declarant.new.as_json
          avis["declarant2"] ||= APIParticulier::Entities::DGFIP::Declarant.new.as_json
          avis.delete("foyer_fiscal")
        end
      end

      def dgfip_foyer_fiscal
        return {} unless @procedure.api_particulier_scope?("dgfip_adresse")

        APIParticulier::Entities::DGFIP::FoyerFiscal.new.as_json
      end

      def caf_allocataires
        return {} unless @procedure.api_particulier_scope?("cnaf_allocataires")

        APIParticulier::Entities::CAF::Personne.new.as_json
      end

      def caf_enfants
        return {} unless @procedure.api_particulier_scope?("cnaf_enfants")

        APIParticulier::Entities::CAF::Personne.new.as_json
      end

      def caf_adresse
        return {} unless @procedure.api_particulier_scope?("cnaf_adresse")

        APIParticulier::Entities::CAF::PosteAdresse.new.as_json
      end

      def caf_quotient_familial
        return {} unless @procedure.api_particulier_scope?("cnaf_quotient_familial")

        APIParticulier::Entities::CAF::Famille.new.as_json.tap do |famille|
          famille.delete("allocataires")
          famille.delete("enfants")
          famille.delete("adresse")
        end
      end

      def pole_emploi_situation
        APIParticulier::Entities::PoleEmploi::SituationPoleEmploi.new.as_json.tap do |situation|
          situation["adresse"] ||= APIParticulier::Entities::PoleEmploi::Adresse.new.as_json
        end
      end

      def mesri_statut_etudiant
        return {} unless @procedure.api_particulier_scope?("mesri_statut_etudiant")

        APIParticulier::Entities::MESRI::Etudiant.new.as_json.tap do |etudiant|
          etudiant["inscriptions"] = APIParticulier::Entities::MESRI::Inscription.new.as_json.tap do |insc|
            insc["etablissement"] ||= APIParticulier::Entities::MESRI::Etablissement.new.as_json
          end
        end
      end
    end
  end
end
