# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Accountability
    module Admin
      describe Admin::ResultsController, type: :controller do
        include Decidim::ApplicationHelper
        include Decidim::SanitizeHelper

        routes { Decidim::Accountability::AdminEngine.routes }

        let(:organization) { create(:organization) }
        let(:current_user) { create(:user, :confirmed, :admin, organization:) }
        let(:participatory_space) { create(:participatory_process, organization:) }
        let!(:component) do
          create(
            :accountability_component,
            participatory_space:
          )
        end
        let(:result) { create(:result, component:) }
        let(:params) { { id: result.id } }

        before do
          request.env["decidim.current_organization"] = organization
          request.env["decidim.current_component"] = component
          sign_in current_user
        end

        describe "GET index" do
          it "renders the index view" do
            get :index, params: {
              participatory_process_slug: participatory_space.slug,
              component_id: component.id
            }

            expect(response).to have_http_status(:ok)
            expect(subject).to render_template("decidim/accountability/admin/results/index")
          end
        end
      end
    end
  end
end
