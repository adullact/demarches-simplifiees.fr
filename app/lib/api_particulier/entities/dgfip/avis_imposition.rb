# frozen_string_literal: true

module APIParticulier
  module Entities
    module DGFIP
      class AvisImposition
        def initialize(**kwargs)
          attrs = kwargs.symbolize_keys
          @declarant1 = attrs[:declarant1]
          @declarant2 = attrs[:declarant2]
          @foyer_fiscal = attrs[:foyerFiscal]
          @date_de_recouvrement = attrs[:dateRecouvrement]
          @date_d_etablissement = attrs[:dateEtablissement]
          @nombre_de_parts = attrs[:nombre_parts]
          @situation_familiale = attrs[:situationFamiliale]
          @nombre_de_personnes_a_charge = attrs[:nombrePersonnesCharge]
          @revenu_brut_global = attrs[:revenuBrutGlobal]
          @revenu_imposable = attrs[:revenuImposable]
          @impot_revenu_net_avant_corrections = attrs[:impotRevenuNetAvantCorrections]
          @montant_de_l_impot = attrs[:montantImpot]
          @revenu_fiscal_de_reference = attrs[:revenuFiscalReference]
          @annee_d_imposition = attrs[:anneeImpots]
          @annee_des_revenus = attrs[:anneeRevenus]
          @erreur_correctif = attrs[:erreurCorrectif]
          @situation_partielle = attrs[:situationPartielle]
        end

        attr_reader :situation_familiale, :erreur_correctif, :situation_partielle

        def declarant1
          Declarant.new(**@declarant1)
        end

        def declarant2
          Declarant.new(**@declarant2)
        end

        def foyer_fiscal
          FoyerFiscal.new(**@foyer_fiscal)
        end

        def date_de_recouvrement
          Date.parse(@date_de_recouvrement)
        rescue Date::Error
          nil
        end

        def date_d_etablissement
          Date.parse(@date_d_etablissement)
        rescue Date::Error
          nil
        end

        def nombre_de_parts
          @nombre_de_parts.to_f
        end

        def nombre_de_personnes_a_charge
          @nombre_de_personnes_a_charge.to_i
        end

        def revenu_brut_global
          @revenu_brut_global.to_i
        end

        def revenu_imposable
          @revenu_imposable.to_i
        end

        def impot_revenu_net_avant_corrections
          @impot_revenu_net_avant_corrections.to_i
        end

        def montant_de_l_impot
          @montant_de_l_impot.to_i
        end

        def revenu_fiscal_de_reference
          @revenu_fiscal_de_reference.to_i
        end

        def annee_d_imposition
          @annee_d_imposition.to_i
        end

        def annee_des_revenus
          @annee_des_revenus.to_i
        end
      end
    end
  end
end
