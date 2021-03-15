# frozen_string_literal: true

module APIParticulier
  module Entities
    module DGFIP
      class Declarant
        def initialize(**kwargs)
          attrs = kwargs.symbolize_keys
          @nom = attrs[:nom]
          @nom_de_naissance = attrs[:nomNaissance]
          @prenoms = attrs[:prenoms]
          @date_de_naissance = attrs[:dateNaissance]
        end

        attr_reader :nom, :nom_de_naissance, :prenoms

        def date_de_naissance
          Date.parse(@date_de_naissance)
        rescue Date::Error
          nil
        end
      end
    end
  end
end
