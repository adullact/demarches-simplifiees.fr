# frozen_string_literal: true

require "rails_helper"

module Maintenance
  RSpec.describe T20260916nullifyBlankAPIEntrepriseTokenTask do
    # `validates_associated :api_entreprise_token` accepts a blank token, so the
    # legacy value plants like any other.
    let(:procedure) { create(:procedure, api_entreprise_token: '') }

    describe "#collection" do
      subject(:collection) { described_class.new.collection }

      it "selects the procedures with a blank token" do
        expect(collection).to include(procedure)
      end

      it "reaches the discarded procedures too" do
        procedure.discard!

        expect(collection).to include(procedure)
      end

      it "leaves out the procedures with a token of their own or none" do
        with_token = create(:procedure)
        without_token = create(:procedure, api_entreprise_token: nil)

        expect(collection).not_to include(with_token, without_token)
      end
    end

    describe "#process" do
      def run! = described_class.new.process(procedure)

      it "nullifies the blank token" do
        expect { run! }.to change { procedure.reload[:api_entreprise_token] }.from('').to(nil)
      end

      it "does not date the procedure" do
        expect { run! }.not_to change { procedure.reload.updated_at }
      end
    end
  end
end
