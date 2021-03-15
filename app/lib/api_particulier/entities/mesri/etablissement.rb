# frozen_string_literal: true

module APIParticulier
  module Entities
    module MESRI
      class Etablissement
        def initialize(**kwargs)
          attrs = kwargs.symbolize_keys
          @uai = attrs[:uai]
          @nom = attrs[:nom]
        end

        attr_reader :uai, :nom
      end
    end
  end
end
