# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Conferences
    describe Decidim::Api::QueryType do
      include_context "with a graphql class type"

      describe "conferences" do
        let!(:conference1) { create(:conference, organization: current_organization) }
        let!(:conference2) { create(:conference, organization: current_organization) }
        let!(:conference3) { create(:conference) }

        let(:query) { %({ conferences { id }}) }

        it "returns all the conferencees" do
          expect(response["conferences"]).to include("id" => conference1.id.to_s)
          expect(response["conferences"]).to include("id" => conference2.id.to_s)
          expect(response["conferences"]).not_to include("id" => conference3.id.to_s)
        end
      end

      describe "conference" do
        let(:query) { %({ conference(id: \"#{id}\") { id }}) }

        context "with a participatory conference that belongs to the current organization" do
          let!(:conference) { create(:conference, organization: current_organization) }
          let(:id) { conference.id }

          it "returns the conference" do
            expect(response["conference"]).to eq("id" => conference.id.to_s)
          end
        end

        context "with a conference of another organization" do
          let!(:conference) { create(:conference) }
          let(:id) { conference.id }

          it "returns nil" do
            expect(response["conference"]).to be_nil
          end
        end
      end
    end
  end
end
