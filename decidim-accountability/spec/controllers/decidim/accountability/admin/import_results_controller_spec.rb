# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Accountability
    module Admin
      describe ImportResultsController, type: :controller do
        routes { Decidim::Accountability::AdminEngine.routes }

        let(:organization) { create(:organization) }
        let(:current_user) { create(:user, :confirmed, :admin, organization:) }
        let(:params) { { participatory_process_slug: participatory_space.slug, component_id: component.id } }
        let!(:component) do
          create(
            :accountability_component,
            participatory_space:
          )
        end

        before do
          request.env["decidim.current_organization"] = organization
          request.env["decidim.current_component"] = component
          sign_in current_user
        end

        shared_examples "renders the import new result page" do
          describe "GET the import result process new" do
            before do
              get :new, params:
            end

            it "renders the import result form" do
              expect(response).to render_template("decidim/accountability/admin/import_results/new")
            end
          end
        end

        describe "when in a participatory process" do
          let(:participatory_space) { create(:participatory_process, organization:) }

          it_behaves_like "renders the import new result page"
        end

        describe "when in an assembly" do
          let(:participatory_space) { create(:assembly, organization:) }

          it_behaves_like "renders the import new result page"
        end
      end
    end
  end
end
