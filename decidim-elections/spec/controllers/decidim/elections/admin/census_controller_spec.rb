# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Elections
    module Admin
      describe CensusController do
        let(:component) { create(:elections_component) }
        let(:organization) { component.organization }
        let(:election) { create(:election, component:) }
        let(:current_user) { create(:user, :admin, :confirmed, organization:) }
        let(:valid_file) { upload_test_file(Decidim::Dev.test_file("valid_election_census.csv", "text/csv")) }
        let(:invalid_file) { upload_test_file(Decidim::Dev.test_file("invalid.jpeg", "image/jpeg")) }
        let(:election_census_path) { Decidim::EngineRouter.admin_proxy(component).election_census_path(election) }
        let(:dashboard_election_path) { Decidim::EngineRouter.admin_proxy(component).dashboard_page_election_path(election) }

        before do
          request.env["decidim.current_organization"] = organization
          request.env["decidim.current_participatory_space"] = component.participatory_space
          request.env["decidim.current_component"] = component
          allow(controller).to receive(:election_census_path).with(election).and_return(election_census_path)
          allow(controller).to receive(:dashboard_page_election_path).with(election).and_return(dashboard_election_path)
          sign_in current_user
        end

        describe "GET edit" do
          it "renders the edit page" do
            get :edit, params: { id: election.id }

            expect(response).to be_successful
            expect(response).to render_template(:edit)
          end
        end

        describe "PATCH update" do
          context "with a valid CSV file" do
            let(:params) { { id: election.id, manifest: :token_csv, file: valid_file } }

            it "processes the census and redirects with a success message" do
              patch :update, params: params

              expect(flash[:notice]).to eq(I18n.t("decidim.elections.admin.census.update.success"))
              expect(response).to redirect_to(dashboard_election_path)
            end
          end

          context "with an invalid file" do
            let(:params) { { id: election.id, manifest: :token_csv, file: invalid_file } }

            it "renders the edit view with an error message" do
              patch :update, params: params

              expect(flash[:alert]).to eq(I18n.t("decidim.elections.admin.census.update.error"))
              expect(response).to render_template(:edit)
            end
          end

          context "when no file is provided" do
            it "renders the edit view with an error message" do
              patch :update, params: { id: election.id, manifest: :token_csv }

              expect(flash[:alert]).to be_present
              expect(response).to render_template(:edit)
            end
          end

          context "when manifest param is present" do
            it "sets the census_manifest on the election" do
              patch :update, params: { id: election.id, manifest: :token_csv, file: valid_file }
              expect(election.reload.census_manifest).to eq("token_csv")
            end
          end
        end
      end
    end
  end
end
