# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Accountability
    module Admin
      describe ImportResultsController, type: :controller do
        routes { Decidim::Accountability::AdminEngine.routes }

        let(:organization) { create(:organization) }
        let(:current_user) { create(:user, :confirmed, :admin, organization: organization) }
        let(:participatory_space) { create(:participatory_process, organization: organization) }
        let!(:component) do
          create(
            :accountability_component,
            participatory_space: participatory_space
          )
        end
        let(:params) { { participatory_process_slug: participatory_space.slug, component_id: component.id } }

        before do
          request.env["decidim.current_organization"] = organization
          request.env["decidim.current_component"] = component
          sign_in current_user
        end

        describe "GET the import result process new" do
          before do
            get :new, params: params
          end

          it "renders the import result form" do
            expect(response).to render_template("decidim/accountability/admin/import_results/new")
          end
        end
      end
    end
  end
end
