# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Core
    describe OrganizationType do
      subject { described_class }

      include_context "with a graphql class type"

      let(:model) do
        current_organization
      end

      describe "name" do
        let(:query) { "{ name }" }

        it "returns the organization's name" do
          expect(response).to eq("name" => model.name)
        end
      end

      describe "stats" do
        let(:query) { %({ stats { name value } }) }
        let!(:confirmed_users) { create_list(:user, 5, :confirmed, organization: model) }
        let!(:unconfirmed_users) { create_list(:user, 2, organization: model) }

        it "show all the stats for this organization" do
          expect(response["stats"]).to include("name" => "users_count", "value" => 5)
        end
      end
    end
  end
end
