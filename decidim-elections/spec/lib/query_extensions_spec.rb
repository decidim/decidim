# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Votings
    describe Decidim::Api::QueryType do
      include_context "with a graphql class type"

      describe "votings" do
        let!(:voting1) { create(:voting, organization: current_organization) }
        let!(:voting2) { create(:voting, organization: current_organization) }
        let!(:voting3) { create(:voting) }
        let!(:voting4) { create(:voting, :unpublished, organization: current_organization) }

        let(:query) { %({ votings { id }}) }

        it "returns all the votings" do
          expect(response["votings"]).to include("id" => voting1.id.to_s)
          expect(response["votings"]).to include("id" => voting2.id.to_s)
          expect(response["votings"]).not_to include("id" => voting3.id.to_s)
          expect(response["votings"]).not_to include("id" => voting4.id.to_s)
        end
      end

      describe "voting" do
        let(:query) { %({ voting(id: \"#{id}\") { id }}) }

        context "with a voting that belongs to the current organization" do
          let!(:voting) { create(:voting, organization: current_organization) }
          let(:id) { voting.id }

          it "returns the voting" do
            expect(response["voting"]).to eq("id" => voting.id.to_s)
          end
        end

        context "with a conference of another organization" do
          let!(:voting) { create(:voting) }
          let(:id) { voting.id }

          it "returns nil" do
            expect(response["voting"]).to be_nil
          end
        end
      end
    end
  end
end
