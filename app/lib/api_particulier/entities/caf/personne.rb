# frozen_string_literal: true

module APIParticulier
  module Entities
    module CAF
      class Personne
        def initialize(**kwargs)
          attrs = kwargs.symbolize_keys
          @noms_et_prenoms = attrs[:nomPrenom]
          @date_de_naissance = attrs[:dateDeNaissance]
          @sexe = attrs[:sexe]
        end

        attr_reader :noms_et_prenoms

        # Date de naissance au format: JJMMAAAA
        def date_de_naissance
          Date.strptime(@date_de_naissance, "%d%m%Y")
        rescue Date::Error
          nil
        end

        def sexe
          APIParticulier::Types::Sexe[@sexe]
        rescue ArgumentError
          nil
        end
      end
    end
  end
end
