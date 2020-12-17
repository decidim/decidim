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
        let(:current_user) { create(:user, :confirmed, :admin, organization: organization) }
        let(:participatory_space) { create(:participatory_process, organization: organization) }
        let!(:component) do
          create(
            :accountability_component,
            participatory_space: participatory_space
          )
        end
        let(:result) { create(:result, component: component) }
        let(:params) { { id: result.id } }

        before do
          request.env["decidim.current_organization"] = organization
          request.env["decidim.current_component"] = component
          sign_in current_user
        end

        describe "GET index" do
          let!(:results) { create_list(:result, 5, component: component) }
          let(:results_count) { results.size }

          it "shows the number of results for a component" do
            # visit_component_admin
            visit decidim_admin_participatory_process_accountability.results_path(
              component_id: component.id,
              participatory_process_slug: participatory_space.slug
            )

            within ".subscribed_count" do
              expect(page).to have_content(results_count)
            end
          end
        end

        describe "GET the proposals picker" do
          before do
            get :proposals_picker, params: params
          end

          it "renders the proposals picker" do
            expect(response).to render_template("decidim/accountability/admin/results/proposals_picker")
          end

          context "when filtering proposals" do
            let(:params) { { q: "a", id: result.id } }

            it "renders the proposals picker" do
              expect(response).to render_template("decidim/accountability/admin/results/proposals_picker")
            end
          end
        end
      end
    end
  end
end
