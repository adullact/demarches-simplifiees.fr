# frozen_string_literal: true

module APIParticulier
  module Services
    class BuildData
      def call(**kwargs)
        raw = kwargs.deep_symbolize_keys

        {
          dgfip: dgfip(**raw),
          caf: caf(**raw),
          pole_emploi: pole_emploi(**raw),
          mesri: mesri(**raw)
        }
      end

      private

      def dgfip(**raw)
        avis = raw.dig(:dgfip, :avis_imposition)
        return if avis.blank?

        avis[:foyer_fiscal] = raw.dig(:dgfip, :foyer_fiscal)
        APIParticulier::Entities::DGFIP::AvisImposition.new(avis)
      end

      def caf(**raw)
        famille = raw[:caf]
        return if famille.blank?

        APIParticulier::Entities::CAF::Famille.new(famille)
      end

      def pole_emploi(**raw)
        situation = raw.dig(:pole_emploi, :situation)
        return if situation.blank?

        APIParticulier::Entities::PoleEmploi::SituationPoleEmploi.new(situation)
      end

      def mesri(**raw)
        etudiant = raw.dig(:mesri, :statut_etudiant)
        return if etudiant.blank?

        APIParticulier::Entities::MESRI::Etudiant.new(etudiant)
      end
    end
  end
end
