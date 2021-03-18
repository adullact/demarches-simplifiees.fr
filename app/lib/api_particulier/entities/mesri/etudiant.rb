# frozen_string_literal: true

module APIParticulier
  module Entities
    module MESRI
      class Etudiant
        def initialize(**kwargs)
          attrs = kwargs.symbolize_keys
          @ine = attrs[:ine]
          @nom = attrs[:nom]
          @prenom = attrs[:prenom]
          @date_de_naissance = attrs[:dateNaissance]
          @inscriptions = attrs[:inscriptions]
        end

        attr_reader :ine, :nom, :prenom

        def date_de_naissance
          DateTime.parse(@date_de_naissance)
        rescue Date::Error
          nil
        end

        def inscriptions
          Array(@inscriptions).map { |kwargs| Inscription.new(**Hash(kwargs)) }
        end
      end
    end
  end
end
