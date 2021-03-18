# frozen_string_literal: true

module APIParticulier
  module Services
    class FetchData
      def initialize(dossier, **kwargs)
        deps = kwargs.symbolize_keys
        @api = deps[:api]
        @dossier = dossier
      end

      def call
        {
          dgfip: dgfip,
          caf: caf,
          pole_emploi: pole_emploi,
          mesri: mesri
        }
      end

      private

      attr_reader :dossier

      def individual
        @individual ||= dossier.individual
      end

      def procedure
        @procedure ||= dossier.procedure
      end

      def api_particulier_token
        @api_particulier_token ||= procedure.api_particulier_token
      end

      def api
        @api || APIParticulier::API.new(token: api_particulier_token)
      end

      def dgfip
        {
          avis_imposition: dgfip_avis_imposition,
          foyer_fiscal: dgfip_foyer_fiscal
        }.compact
      end

      def fetch_dgfip
        @fetch_dgfip ||= api.avis_d_imposition(
          numero_fiscal: individual.api_particulier_dgfip_numero_fiscal,
          reference_de_l_avis: individual.api_particulier_dgfip_reference_de_l_avis
        )
      end

      def dgfip_avis_imposition
        return unless procedure.api_particulier_scope?("dgfip_avis_imposition")

        fetch_dgfip.dup.tap(&:ignore_foyer_fiscal!)
      end

      def dgfip_foyer_fiscal
        return unless procedure.api_particulier_scope?("dgfip_adresse")

        fetch_dgfip.foyer_fiscal
      end

      def caf
        {
          allocataires: caf_allocataires,
          enfants: caf_enfants,
          adresse: caf_adresse
        }.merge(caf_quotient_familial).compact
      end

      def fetch_caf
        @fetch_caf ||= api.composition_familiale(
          numero_d_allocataire: individual.api_particulier_caf_numero_d_allocataire,
          code_postal: individual.api_particulier_caf_code_postal
        )
      end

      def caf_allocataires
        return unless procedure.api_particulier_scope?("cnaf_allocataires")

        fetch_caf.allocataires
      end

      def caf_enfants
        return unless procedure.api_particulier_scope?("cnaf_enfants")

        fetch_caf.enfants
      end

      def caf_adresse
        return unless procedure.api_particulier_scope?("cnaf_adresse")

        fetch_caf.adresse
      end

      def caf_quotient_familial
        return {} unless procedure.api_particulier_scope?("cnaf_quotient_familial")

        fetch_caf.as_json.symbolize_keys.slice(:quotient_familial, :annee, :mois)
      end

      def pole_emploi
        { situation: pole_emploi_situation }.compact
      end

      def fetch_pole_emploi
        @fetch_pole_emploi ||= api.situation_pole_emploi(
          identifiant: individual.api_particulier_pole_emploi_identifiant
        )
      end

      def pole_emploi_situation
        # FIXME: use the correct scope name once known
        return unless procedure.api_particulier_scope?("inconnu")

        fetch_pole_emploi
      end

      def mesri
        { statut_etudiant: mesri_statut_etudiant }.compact
      end

      def fetch_mesri
        @fetch_mesri ||= api.etudiants(ine: individual.api_particulier_mesri_ine)
      end

      def mesri_statut_etudiant
        return unless procedure.api_particulier_scope?("mesri_statut_etudiant")

        fetch_mesri
      end
    end
  end
end
