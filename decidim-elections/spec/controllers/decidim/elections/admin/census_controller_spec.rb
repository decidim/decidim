# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Elections
    module Admin
      describe CensusController do
        routes { Decidim::Elections::AdminEngine.routes }

        let(:component) { create(:elections_component) }
        let(:organization) { component.organization }
        let(:election) { create(:election, component:) }
        let(:current_user) { create(:user, :admin, :confirmed, organization:) }
        let(:csv_content) do
          "email;token\nuser1@example.com;token1\nuser2@example.com;token2"
        end

        before do
          request.env["decidim.current_organization"] = organization
          request.env["decidim.current_participatory_space"] = component.participatory_space
          request.env["decidim.current_component"] = component
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
          context "with census_permissions param (internal census)" do
            before do
              allow(organization).to receive(:available_authorizations).and_return(["email_authorization"])
              create(:user, :confirmed, organization:).tap do |user|
                create(:authorization, name: "email_authorization", granted_at: 1.day.ago, user:)
              end
            end

            it "creates internal census and redirects" do
              patch :update, params: {
                id: election.id,
                census_permissions: {
                  verification_types: ["email_authorization"]
                }
              }

              expect(response).to redirect_to(election_census_path(election))
              expect(flash[:notice]).to be_present
              expect(election.reload).to be_internal_census
            end
          end

          context "with csv file (external census)" do
            let(:valid_csv_content) { "email;token\nvoter1@example.org;token1\nvoter2@example.org;token2" }
            let(:invalid_content) { "invalid content" }
            let(:empty_content) { "" }
            let(:valid_file) { upload_test_file(Decidim::Dev.test_file("valid_election_census.csv", "text/csv")) }
            let(:invalid_file) { upload_test_file(Decidim::Dev.test_file("invalid.jpeg", "image/jpeg")) }
            let(:empty_file) { upload_test_file(Decidim::Dev.test_file("empty_file.csv", "text/csv")) }

            it "creates external census and redirects" do
              patch :update, params: { id: election.id, census_data: { file: valid_file } }

              expect(response).to redirect_to(election_census_path(election))
              expect(flash[:notice]).to be_present
            end

            it "renders edit when file is missing" do
              patch :update, params: { id: election.id }

              expect(response).to render_template(:edit)
              expect(flash[:alert]).to be_present
            end

            it "renders edit when file is not csv" do
              patch :update, params: { id: election.id, file: invalid_file }

              expect(response).to render_template(:edit)
              expect(flash[:alert]).to be_present
            end

            it "renders edit when csv file is empty" do
              patch :update, params: { id: election.id, file: empty_file }

              expect(response).to render_template(:edit)
              expect(flash[:alert]).to be_present
            end
          end
        end

        describe "DELETE destroy_all" do
          before do
            allow(Decidim::Elections::Voter).to receive(:clear)
          end

          it "clears all voters and redirects" do
            delete :destroy_all, params: { id: election.id }

            expect(response).to redirect_to(election_census_path(election))
            expect(flash[:notice]).to be_present
            expect(Decidim::Elections::Voter).to have_received(:clear).with(election)
          end
        end
      end
    end
  end
end
