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
        let(:query) { %({ name { translation(locale: "en") }}) }

        it "returns the organization's name" do
          expect(response["name"]["translation"]).to eq(translated(model.name))
        end
      end

      describe "stats" do
        let(:query) { %({ stats { name value } }) }
        let!(:confirmed_users) { create_list(:user, 4, :confirmed, organization: model) }
        let!(:unconfirmed_users) { create_list(:user, 2, organization: model) }

        it "show all the stats for this organization" do
          # shows 5 as user_count, as we have the 4 confirmed_users + the admin
          expect(response["stats"]).to include("name" => "users_count", "value" => 5)
        end
      end

      describe "taxonomies" do
        let(:query) { %({ taxonomies { id } }) }
        let!(:root_taxonomy) { create(:taxonomy, organization: model) }
        let!(:taxonomy) { create(:taxonomy, parent: root_taxonomy, organization: model) }

        it "has root taxonomies only" do
          expect(response["taxonomies"]).to contain_exactly("id" => root_taxonomy.id.to_s)
        end
      end
    end
  end
end
