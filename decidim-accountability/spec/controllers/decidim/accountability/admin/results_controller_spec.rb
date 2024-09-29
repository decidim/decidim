# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Accountability
    module Admin
      describe Admin::ResultsController do
        include Decidim::ApplicationHelper

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

        describe "PATCH soft_delete" do
          it "soft deletes a result" do
            patch(:soft_delete, params:)

            expect(result.reload.deleted_at).not_to be_nil
            expect(response).to redirect_to(results_path(parent_id: result.parent_id))
          end
        end

        describe "PATCH restore" do
          it "restores a soft deleted result" do
            result.trash!
            patch(:restore, params:)

            expect(result.reload.deleted_at).to be_nil
            expect(response).to redirect_to(manage_trash_results_path(parent_id: result.parent_id))
          end
        end

        describe "GET manage_trash" do
          it "renders the manage_trash view" do
            get :manage_trash

            expect(response).to have_http_status(:ok)

            expect(subject).to render_template(:manage_trash)
          end
        end
      end
    end
  end
end
