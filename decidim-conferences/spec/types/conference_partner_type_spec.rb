# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Conferences
    describe ConferencePartnerType, type: :graphql do
      include_context "with a graphql class type"

      let(:model) { create(:partner) }

      describe "id" do
        let(:query) { "{ id }" }

        it "returns the id field" do
          expect(response["id"]).to eq(model.id.to_s)
        end
      end

      describe "name" do
        let(:query) { "{ name }" }

        it "returns the conference' name" do
          expect(response["name"]).to eq(model.name)
        end
      end

      describe "partnerType" do
        let(:query) { "{ partnerType }" }

        it "returns the conference' partnerType" do
          expect(response["partnerType"]).to eq(model.partner_type)
        end
      end

      describe "weight" do
        let(:query) { "{ weight }" }

        it "returns the conference partner' weight" do
          expect(response["weight"]).to eq(model.weight)
        end
      end

      describe "link" do
        let(:query) { "{ link }" }

        it "returns the conference partner' link" do
          expect(response["link"]).to eq(model.link)
        end
      end

      describe "logo" do
        let(:query) { "{ logo }" }

        it "returns the logo for this partner" do
          expect(response["logo"]).to eq(model.attached_uploader(:logo).path)
        end
      end

      describe "createdAt" do
        let(:query) { "{ createdAt }" }

        it "returns when the conference partner was created" do
          expect(response["createdAt"]).to eq(model.created_at.to_time.iso8601)
        end
      end

      describe "updatedAt" do
        let(:query) { "{ updatedAt }" }

        it "returns when the conference partner was updated" do
          expect(response["updatedAt"]).to eq(model.updated_at.to_time.iso8601)
        end
      end
    end
  end
end
