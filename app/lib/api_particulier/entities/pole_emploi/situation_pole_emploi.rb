# frozen_string_literal: true

module APIParticulier
  module Entities
    module PoleEmploi
      class SituationPoleEmploi
        def initialize(**kwargs)
          attrs = kwargs.symbolize_keys
          @email = attrs[:email]
          @nom = attrs[:nom]
          @nom_d_usage = attrs[:nomUsage]
          @prenom = attrs[:prenom]
          @identifiant = attrs[:identifiant]
          @sexe = attrs[:sexe]
          @date_de_naissance = attrs[:dateNaissance]
          @date_d_inscription = attrs[:dateInscription]
          @date_de_radiation = attrs[:dateRadiation]
          @date_de_la_prochaine_convocation = attrs[:dateProchaineConvocation]
          @categorie_d_inscription = attrs[:categorieInscription]
          @code_de_certification_cnav = attrs[:codeCertificationCNAV]
          @telephone = attrs[:telephone]
          @telephone2 = attrs[:telephone2]
          @civilite = attrs[:civilite]
          @adresse = attrs[:adresse]
        end

        attr_reader :email, :nom, :nom_d_usage, :prenom, :identifiant, :categorie_d_inscription,
                    :code_de_certification_cnav, :civilite

        def sexe
          APIParticulier::Types::Sexe[@sexe]
        rescue ArgumentError
          nil
        end

        def date_de_naissance
          DateTime.parse(@date_de_naissance)
        rescue Date::Error
          nil
        end

        def date_d_inscription
          DateTime.parse(@date_d_inscription)
        rescue Date::Error
          nil
        end

        def date_de_radiation
          DateTime.parse(@date_de_radiation)
        rescue Date::Error
          nil
        end

        def date_de_la_prochaine_convocation
          DateTime.parse(@date_de_la_prochaine_convocation)
        rescue Date::Error
          nil
        end

        def telephones
         [@telephone, @telephone2].compact
        end

        def adresse
          Adresse.new(**Hash(@adresse))
        end
      end
    end
  end
end
