# frozen_string_literal: true

module APIParticulier
  module Services
    class BuildProcedureMask
      def call(procedure)
        {
          dgfip: dgfip(procedure),
          caf: caf(procedure),
          pole_emploi: pole_emploi(procedure),
          mesri: mesri(procedure)
        }.deep_symbolize_keys
      end

      private

      def dgfip(procedure)
        {
          avis_imposition: dgfip_avis_imposition(procedure),
          foyer_fiscal: dgfip_foyer_fiscal(procedure)
        }.compact
      end

      def dgfip_avis_imposition(procedure)
        return unless procedure.api_particulier_scope?("dgfip_avis_imposition")

        APIParticulier::Entities::DGFIP::AvisImposition.new.as_json.tap do |avis|
          avis["declarant1"] ||= APIParticulier::Entities::DGFIP::Declarant.new.as_json
          avis["declarant2"] ||= APIParticulier::Entities::DGFIP::Declarant.new.as_json
          avis.delete("foyer_fiscal")
        end
      end

      def dgfip_foyer_fiscal(procedure)
        return unless procedure.api_particulier_scope?("dgfip_adresse")

        APIParticulier::Entities::DGFIP::FoyerFiscal.new.as_json
      end

      def caf(procedure)
        {
          allocataires: caf_allocataires(procedure),
          enfants: caf_enfants(procedure),
          adresse: caf_adresse(procedure)
        }.compact.merge(caf_quotient_familial(procedure))
      end

      def caf_allocataires(procedure)
        return unless procedure.api_particulier_scope?("cnaf_allocataires")

        APIParticulier::Entities::CAF::Personne.new.as_json
      end

      def caf_enfants(procedure)
        return unless procedure.api_particulier_scope?("cnaf_enfants")

        APIParticulier::Entities::CAF::Personne.new.as_json
      end

      def caf_adresse(procedure)
        return unless procedure.api_particulier_scope?("cnaf_adresse")

        APIParticulier::Entities::CAF::PosteAdresse.new.as_json
      end

      def caf_quotient_familial(procedure)
        return {} unless procedure.api_particulier_scope?("cnaf_quotient_familial")

        APIParticulier::Entities::CAF::QuotientFamilial.new.as_json
      end

      def pole_emploi(procedure)
        { situation: pole_emploi_situation(procedure) }.compact
      end

      def pole_emploi_situation(procedure)
        # FIXME: use the correct scope name once known
        return unless procedure.api_particulier_scope?("inconnu")

        APIParticulier::Entities::PoleEmploi::SituationPoleEmploi.new.as_json.tap do |situation|
          situation["adresse"] ||= APIParticulier::Entities::PoleEmploi::Adresse.new.as_json
        end
      end

      def mesri(procedure)
        { statut_etudiant: mesri_statut_etudiant(procedure) }.compact
      end

      def mesri_statut_etudiant(procedure)
        return unless procedure.api_particulier_scope?("mesri_statut_etudiant")

        APIParticulier::Entities::MESRI::Etudiant.new.as_json.tap do |etudiant|
          etudiant["inscriptions"] = APIParticulier::Entities::MESRI::Inscription.new.as_json.tap do |insc|
            insc["etablissement"] ||= APIParticulier::Entities::MESRI::Etablissement.new.as_json
          end
        end
      end
    end
  end
end
