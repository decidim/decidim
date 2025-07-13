# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

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
        let(:query) { %({ stats { name { translation(locale:  "en") } value } }) }
        let!(:confirmed_users) { create_list(:user, 4, :confirmed, organization: model) }
        let!(:unconfirmed_users) { create_list(:user, 2, organization: model) }

        it "shows all the stats for this organization" do
          # As we have 4 confirmed users and the admin (assuming they are counted as confirmed), we expect 5.
          expect(response["stats"]).to include(
            hash_including("name" => { "translation" => "Participants" }, "value" => 5)
          )
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
