# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Conferences
    module Admin
      describe ConferenceRegistrationsController do
        routes { Decidim::Conferences::AdminEngine.routes }

        let(:organization) { create(:organization) }
        let(:current_user) { create(:user, :confirmed, :admin, organization:) }
        let!(:conference) { create(:conference, :published, organization:) }
        let!(:registration_type) { create(:registration_type, conference:) }

        before do
          request.env["decidim.current_organization"] = organization
          sign_in current_user, scope: :user
        end

        describe "GET index" do
          let!(:registration) { create(:conference_registration, conference:, registration_type:) }

          it "lists the conference registrations" do
            get :index, params: { conference_slug: conference.slug }

            expect(response).to have_http_status(:success)
            expect(assigns(:conference_registrations)).to include(registration)
          end

          context "when the user is not an admin" do
            let(:current_user) { create(:user, :confirmed, organization:) }

            it "redirects the user" do
              get :index, params: { conference_slug: conference.slug }

              expect(response).to have_http_status(:redirect)
              expect(flash[:alert]).to be_present
            end
          end
        end

        describe "GET export" do
          let!(:registration) { create(:conference_registration, conference:, registration_type:) }

          it "exports the conference registrations" do
            get :export, params: { conference_slug: conference.slug, format: "CSV" }

            expect(response).to have_http_status(:success)
            expect(response.body).to include(registration.user.email)
            expect(response.headers["Content-Disposition"]).to include("conference_registrations")
          end

          context "when the user is not an admin" do
            let(:current_user) { create(:user, :confirmed, organization:) }

            it "redirects the user" do
              get :export, params: { conference_slug: conference.slug, format: "CSV" }

              expect(response).to have_http_status(:redirect)
              expect(flash[:alert]).to be_present
            end
          end
        end

        describe "POST confirm" do
          let!(:registration) { create(:conference_registration, :unconfirmed, conference:, registration_type:) }

          it "confirms the registration and redirects to the list" do
            post :confirm, params: { conference_slug: conference.slug, id: registration.id }

            expect(registration.reload).to be_confirmed
            expect(response).to redirect_to(conference_conference_registrations_path(conference))
            expect(flash[:notice]).to be_present
          end

          context "when the registrations are disabled" do
            before { conference.update!(registrations_enabled: false) }

            it "does not confirm the registration" do
              post :confirm, params: { conference_slug: conference.slug, id: registration.id }

              expect(registration.reload).not_to be_confirmed
              expect(response).to redirect_to(conference_conference_registrations_path(conference))
              expect(flash[:alert]).to be_present
            end
          end

          context "when the user is not an admin" do
            let(:current_user) { create(:user, :confirmed, organization:) }

            it "does not confirm the registration" do
              post :confirm, params: { conference_slug: conference.slug, id: registration.id }

              expect(registration.reload).not_to be_confirmed
              expect(response).to have_http_status(:redirect)
              expect(flash[:alert]).to be_present
            end
          end
        end
      end
    end
  end
end
