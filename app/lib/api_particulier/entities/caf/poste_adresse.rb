# frozen_string_literal: true

module APIParticulier
  module Entities
    module CAF
      class PosteAdresse
        def initialize(**kwargs)
          attrs = kwargs.symbolize_keys
          @identite = attrs[:identite]
          @complement_d_identite = attrs[:complementIdentite]
          @complement_d_identite_geo = attrs[:complementIdentiteGeo]
          @numero_et_rue = attrs[:numeroRue]
          @lieu_dit = attrs[:lieuDit]
          @code_postal_et_ville = attrs[:codePostalVille]
          @pays = attrs[:pays]
        end

        attr_reader :identite, :complement_d_identite, :complement_d_identite_geo, :numero_et_rue, :lieu_dit,
                    :code_postal_et_ville, :pays
      end
    end
  end
end
