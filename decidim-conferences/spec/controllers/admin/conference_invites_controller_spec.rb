# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Conferences
    module Admin
      describe ConferenceInvitesController do
        routes { Decidim::Conferences::AdminEngine.routes }

        let(:organization) { create(:organization) }
        let(:current_user) { create(:user, :confirmed, :admin, organization:) }
        let!(:conference) { create(:conference, :published, organization:) }
        let!(:registration_type) { create(:registration_type, conference:) }

        before do
          request.env["decidim.current_organization"] = organization
          sign_in current_user
        end

        describe "GET index" do
          let!(:invite) { create(:conference_invite, conference:, registration_type:) }

          it "returns a successful response" do
            get :index, params: { conference_slug: conference.slug }

            expect(response).to have_http_status(:success)
            expect(assigns(:conference_invites)).to include(invite)
          end

          context "when the user is a conference admin" do
            let(:current_user) { create(:conference_admin, :confirmed, organization:, conference:) }

            it "returns a successful response" do
              get :index, params: { conference_slug: conference.slug }

              expect(response).to have_http_status(:success)
            end
          end

          context "when the user is not an admin" do
            let(:current_user) { create(:user, :confirmed, organization:) }

            it "redirects the user" do
              get :index, params: { conference_slug: conference.slug }

              expect(response).to have_http_status(:redirect)
              expect(flash[:alert]).to be_present
            end
          end

          context "when the user is a conference collaborator" do
            let(:current_user) { create(:conference_collaborator, :confirmed, organization:, conference:) }

            it "redirects the user" do
              get :index, params: { conference_slug: conference.slug }

              expect(response).to have_http_status(:redirect)
              expect(flash[:alert]).to be_present
            end
          end
        end

        describe "GET new" do
          it "returns a successful response" do
            get :new, params: { conference_slug: conference.slug }

            expect(response).to have_http_status(:success)
            expect(assigns(:form)).to be_a(ConferenceRegistrationInviteForm)
          end

          context "when the user is not an admin" do
            let(:current_user) { create(:user, :confirmed, organization:) }

            it "redirects the user" do
              get :new, params: { conference_slug: conference.slug }

              expect(response).to have_http_status(:redirect)
              expect(flash[:alert]).to be_present
            end
          end
        end

        describe "POST create" do
          let(:params) do
            {
              conference_slug: conference.slug,
              conference_registration_invite: {
                existing_user: "false",
                name: "John Doe",
                email: "jdoe@example.org",
                registration_type_id: registration_type.id
              }
            }
          end

          it "creates an invite and redirects to the invites list" do
            expect { post :create, params: }.to change(Decidim::Conferences::ConferenceInvite, :count).by(1)

            expect(response).to redirect_to(conference_conference_invites_path(conference))
            expect(flash[:notice]).to be_present
          end

          context "when inviting an existing participant" do
            let!(:existing_user) { create(:user, :confirmed, organization:) }
            let(:params) do
              {
                conference_slug: conference.slug,
                conference_registration_invite: {
                  existing_user: "true",
                  user_id: existing_user.id,
                  registration_type_id: registration_type.id
                }
              }
            end

            it "creates an invite for the existing participant" do
              expect { post :create, params: }.to change(Decidim::Conferences::ConferenceInvite, :count).by(1)

              expect(response).to redirect_to(conference_conference_invites_path(conference))
              expect(Decidim::Conferences::ConferenceInvite.last.user).to eq(existing_user)
            end
          end

          context "when the participant is already invited" do
            let!(:existing_user) { create(:user, :confirmed, organization:) }
            let!(:invite) { create(:conference_invite, conference:, user: existing_user, registration_type:) }
            let(:params) do
              {
                conference_slug: conference.slug,
                conference_registration_invite: {
                  existing_user: "true",
                  user_id: existing_user.id,
                  registration_type_id: registration_type.id
                }
              }
            end

            it "does not create a duplicate invite and renders the form" do
              expect { post :create, params: }.not_to change(Decidim::Conferences::ConferenceInvite, :count)

              expect(response).to have_http_status(:unprocessable_content)
              expect(response).to render_template(:new)
              expect(flash[:alert]).to be_present
            end
          end

          context "when the form is invalid" do
            let(:params) do
              {
                conference_slug: conference.slug,
                conference_registration_invite: {
                  existing_user: "false",
                  name: "",
                  email: "",
                  registration_type_id: registration_type.id
                }
              }
            end

            it "does not create an invite and renders the form" do
              expect { post :create, params: }.not_to change(Decidim::Conferences::ConferenceInvite, :count)

              expect(response).to have_http_status(:unprocessable_content)
              expect(response).to render_template(:new)
              expect(flash[:alert]).to be_present
            end
          end

          context "when the user is not an admin" do
            let(:current_user) { create(:user, :confirmed, organization:) }

            it "does not create an invite" do
              expect { post :create, params: }.not_to change(Decidim::Conferences::ConferenceInvite, :count)

              expect(response).to have_http_status(:redirect)
              expect(flash[:alert]).to be_present
            end
          end
        end
      end
    end
  end
end
