# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Assemblies
    module Admin
      describe AssemblyFiltersController do
        routes { Decidim::Assemblies::AdminEngine.routes }

        let!(:organization) { create(:organization) }
        let!(:admin) { create(:user, :admin, :confirmed, organization:) }
        let!(:taxonomy1) { create(:taxonomy, :with_parent, organization:) }
        let!(:taxonomy2) { create(:taxonomy, :with_parent, organization:) }
        let!(:taxonomy_filter1) { create(:taxonomy_filter, root_taxonomy: taxonomy1.parent, space_manifest: "assemblies") }
        let!(:taxonomy_filter2) { create(:taxonomy_filter, root_taxonomy: taxonomy2.parent, space_manifest: "assemblies") }
        let!(:another_taxonomy_filter2) { create(:taxonomy_filter, root_taxonomy: taxonomy2.parent) }

        before do
          request.env["decidim.current_organization"] = organization
          sign_in admin, scope: :user
        end

        it "helper collection returns available filters" do
          expect(controller.helpers.collection).to contain_exactly(taxonomy_filter1, taxonomy_filter2)
        end

        it "helper root_taxonomies returns available root taxonomies" do
          expect(controller.helpers.root_taxonomies).to contain_exactly(taxonomy1.parent, taxonomy2.parent)
        end

        it "helper current_taxonomy_filter returns the current filter" do
          get :new, params: { id: taxonomy_filter1.id }

          expect(controller.helpers.current_taxonomy_filter).to eq(taxonomy_filter1)
        end

        it "helper breadcrumb_manage_partial returns the correct partial" do
          expect(controller.helpers.breadcrumb_manage_partial).to eq("layouts/decidim/admin/manage_assemblies")
        end
      end
    end
  end
end
