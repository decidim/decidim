# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Accountability
    module Admin
      describe ProjectsImportController, type: :controller do
        routes { Decidim::Accountability::AdminEngine.routes }
        describe "GET show" do
          let(:current_user) { create(:user, :confirmed, :admin, organization:) }
          let(:organization) { create(:organization) }
          let(:component) { create(:component, manifest_name: "accountability", published_at: Time.current) }

          before do
            request.env["decidim.current_organization"] = organization
            request.env["decidim.current_component"] = component
            sign_in current_user
          end

          it "renders the import result form" do
            get :new
            expect(response).to have_http_status(:ok)
            expect(response).to render_template("decidim/accountability/admin/projects_import/new")
          end
        end
      end
    end
  end
end
