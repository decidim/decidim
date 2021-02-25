# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Elections
    describe TrusteeType, type: :graphql do
      include_context "with a graphql class type"

      let(:model) { create(:trustee) }

      describe "id" do
        let(:query) { "{ id }" }

        it "returns all the required fields" do
          expect(response).to include("id" => model.id.to_s)
        end
      end

      describe "user" do
        let(:query) { "{ user { name } }" }

        it "returns the user field" do
          expect(response["user"]["name"]).to eq(model.user.name)
        end
      end

      describe "publicKey" do
        let(:query) { "{ publicKey }" }

        it "returns the public key field" do
          expect(response["publicKey"]).to eq(model.public_key)
        end
      end
    end
  end
end
