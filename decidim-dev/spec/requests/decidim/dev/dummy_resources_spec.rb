# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Dev
    describe "Dummy resources" do
      let(:organization) { create(:organization) }
      let(:component) { create(:dummy_component, organization:) }
      let(:resource) { create(:dummy_resource, component:) }

      before do
        host! organization.host
      end

      it "shows a resource from the current component" do
        get Decidim::EngineRouter.main_proxy(component).dummy_resource_path(resource.id)

        expect(response).to have_http_status(:ok)
        expect(response.body).to have_escaped_html(translated(resource.title))
      end

      context "when the resource belongs to another organization" do
        let(:other_component) { create(:dummy_component, organization: create(:organization)) }
        let(:other_resource) { create(:dummy_resource, component: other_component) }

        it "returns not found" do
          get Decidim::EngineRouter.main_proxy(component).dummy_resource_path(other_resource.id)

          expect(response).to have_http_status(:not_found)
        end
      end

      context "when the resource belongs to another component in the same organization" do
        let(:other_component) { create(:dummy_component, organization:) }
        let(:other_resource) { create(:dummy_resource, component: other_component) }

        it "returns not found" do
          get Decidim::EngineRouter.main_proxy(component).dummy_resource_path(other_resource.id)

          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end
end
