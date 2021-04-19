# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/core/test"

module Decidim
  module Core
    describe ComponentInputFilter, type: :graphql do
      include_context "with a graphql class type"
      let(:type_class) { Decidim::ParticipatoryProcesses::ParticipatoryProcessType }

      let(:model) { create(:participatory_process, organization: current_organization) }
      let!(:proposal) { create(:proposal_component, :published, participatory_space: model) }
      let!(:dummy) { create(:component, :published, participatory_space: model) }

      context "when no filters are applied" do
        let(:query) { %[{ components(filter: {}) { id } }] }

        it "returns all the types" do
          ids = response["components"].map { |component| component["id"].to_i }
          expect(ids).to include(*proposal.id)
          expect(ids).to include(*dummy.id)
        end
      end

      context "when filtering by type" do
        let(:query) { %[{ components(filter: { type: "proposals" }) { id } }] }

        it "returns the types requested" do
          ids = response["components"].map { |component| component["id"].to_i }
          expect(ids).to include(*proposal.id)
          expect(ids).not_to include(*dummy.id)
        end
      end

      context "when type is not present" do
        let(:query) { %[{ components(filter: { type: "other_type" }) { id } }] }

        it "returns an empty array" do
          expect(response["components"]).to eq([])
        end
      end

      context "when searching components with comments enabled" do
        let(:query) { "{ components(filter: { withCommentsEnabled: true} ) { id } }" }

        it "returns the component with comments enabled" do
          ids = response["components"].map { |component| component["id"].to_i }
          expect(ids).to include(*proposal.id)
        end
      end

      context "when searching components with comments not enabled" do
        let!(:model_with_comments_disabled) { create(:proposal_component, :with_comments_disabled, participatory_space: model) }
        let(:query) { "{ components(filter: { withCommentsEnabled: false } ) { id } }" }

        it "returns the component with comments not enabled" do
          ids = response["components"].map { |component| component["id"].to_i }
          expect(ids).to include(*model_with_comments_disabled.id)
        end
      end

      context "when searching components with geocoding enabled" do
        let!(:model_with_geocoding_enabled) { create(:proposal_component, :published, :with_geocoding_enabled, participatory_space: model) }
        let(:query) { "{ components(filter: { withGeolocationEnabled: true} ) { id } }" }

        it "returns the component with geocoding enabled" do
          ids = response["components"].map { |component| component["id"].to_i }
          expect(ids).to include(*model_with_geocoding_enabled.id)
        end
      end

      context "when searching components with geocoding not enabled" do
        let(:query) { "{ components(filter: { withGeolocationEnabled: false } ) { id } }" }

        it "returns the component with geocoding disabled" do
          ids = response["components"].map { |component| component["id"].to_i }
          expect(ids).to include(*proposal.id)
        end
      end

      context "when searching for name without locale" do
        let(:query) { %[{ components(filter: { name: "Proposals" }) { id } }] }

        it "returns the components requested" do
          ids = response["components"].map { |component| component["id"].to_i }
          expect(ids).to include(*proposal.id)
        end
      end

      context "when searching for name with locale" do
        let(:query) { %[{ components(filter: { name: "Propostes", locale: "ca" }) { id } }] }

        it "returns the components requested" do
          ids = response["components"].map { |component| component["id"].to_i }
          expect(ids).to include(*proposal.id)
        end
      end

      context "when searching for name with wrong locale" do
        let(:query) { %[{ components(filter: { name: "Proposals", locale: "de" }) { id } }] }

        it "returns the components requested" do
          expect { response }.to raise_exception(Exception)
        end
      end

      context "when searching for name with wrong name" do
        let(:query) { %[{ components(filter: { name: "Decidim" }) { id } }] }

        it "returns an empty array" do
          expect(response["components"]).to eq([])
        end
      end
    end
  end
end
