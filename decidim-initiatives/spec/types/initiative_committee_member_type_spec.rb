# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Initiatives
    describe InitiativeCommitteeMemberType, type: :graphql do
      include_context "with a graphql class type"

      let(:model) { create(:initiatives_committee_member) }

      describe "id" do
        let(:query) { "{ id }" }

        it "returns the id field" do
          expect(response).to include("id" => model.id.to_s)
        end
      end

      describe "user" do
        let(:query) { "{ user { name } }" }

        it "returns the user field" do
          expect(response["user"]["name"]).to eq(model.user.name)
        end
      end

      describe "createdAt" do
        let(:query) { "{ createdAt }" }

        it "returns when the initiative type was created" do
          expect(response["createdAt"]).to eq(model.created_at.to_time.iso8601)
        end
      end

      describe "updatedAt" do
        let(:query) { "{ updatedAt }" }

        it "returns when the initiative type was updated" do
          expect(response["updatedAt"]).to eq(model.updated_at.to_time.iso8601)
        end
      end
    end
  end
end
