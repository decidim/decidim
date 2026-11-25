# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Conferences
    describe ConferenceRegistrationsController do
      routes { Decidim::Conferences::Engine.routes }

      include Decidim::Core::Engine.routes.url_helpers

      let(:organization) { create(:organization) }
      let(:user) { create(:user, :confirmed, organization:) }
      let(:registrations_enabled) { true }
      let!(:conference) do
        create(:conference, :published, organization:, registrations_enabled:)
      end
      let!(:registration_type) { create(:registration_type, conference:) }

      before do
        request.env["decidim.current_organization"] = organization
      end

      describe "POST create" do
        let(:params) { { conference_slug: conference.slug, registration_type_id: registration_type.id, locale: I18n.locale } }

        context "when the user is signed in" do
          before { sign_in user, scope: :user }

          it "creates a registration and redirects to the conference" do
            expect { post :create, params: }.to change(ConferenceRegistration, :count).by(1)

            expect(response).to redirect_to(conference_path(conference))
            expect(flash[:notice]).to eq("You have successfully joined the conference.")
          end

          context "when the conference cannot be found" do
            let(:params) { { conference_slug: "unknown", registration_type_id: registration_type.id, locale: I18n.locale } }

            it "does not create a registration" do
              expect { post :create, params: }.not_to change(ConferenceRegistration, :count)

              expect(response).to redirect_to(root_path)
            end
          end

          context "when registrations are disabled" do
            let(:registrations_enabled) { false }

            it "does not create a registration" do
              expect { post :create, params: }.not_to change(ConferenceRegistration, :count)

              expect(response).to redirect_to(root_path)
              expect(flash[:alert]).to be_present
            end
          end

          context "when the user is already registered" do
            let!(:registration) { create(:conference_registration, conference:, user:, registration_type:) }

            it "does not create a duplicate registration" do
              expect { post :create, params: }.not_to change(ConferenceRegistration, :count)

              expect(response).to redirect_to(conference_path(conference))
            end
          end
        end

        context "when the user is not signed in" do
          it "does not create a registration and redirects to sign in" do
            expect { post :create, params: }.not_to change(ConferenceRegistration, :count)

            expect(response).to redirect_to(new_user_session_path)
            expect(flash[:alert]).to eq("You need to log in before registering to the conference.")
          end
        end
      end

      describe "DELETE destroy" do
        let!(:registration) { create(:conference_registration, conference:, user:, registration_type:) }
        let(:params) { { conference_slug: conference.slug, registration_type_id: registration_type.id, locale: I18n.locale } }

        context "when the user is signed in" do
          before { sign_in user, scope: :user }

          it "destroys the registration and redirects to the conference" do
            expect { delete :destroy, params: }.to change(ConferenceRegistration, :count).by(-1)

            expect(response).to redirect_to(conference_path(conference))
            expect(flash[:notice]).to eq("You have successfully left the conference.")
          end

          context "when the user has no registration" do
            let!(:registration) { nil }

            it "does not destroy anything" do
              expect { delete :destroy, params: }.not_to change(ConferenceRegistration, :count)

              expect(response).to redirect_to(conference_path(conference))
              expect(flash[:alert]).to be_present
            end
          end
        end

        context "when the user is not signed in" do
          it "does not destroy the registration and redirects to sign in" do
            expect { delete :destroy, params: }.not_to change(ConferenceRegistration, :count)

            expect(response).to redirect_to(new_user_session_path)
          end
        end
      end

      describe "GET decline_invitation" do
        let(:params) { { conference_slug: conference.slug, registration_type_id: registration_type.id, locale: I18n.locale } }

        context "when the user is invited and signed in" do
          let!(:invite) { create(:conference_invite, conference:, user:, registration_type:) }

          before do
            sign_in user, scope: :user
            get :decline_invitation, params:
          end

          it "declines the invitation and redirects to the conference" do
            expect(invite.reload.rejected_at).to be_present
            expect(response).to redirect_to(conference_path(conference))
            expect(flash[:notice]).to eq("You have successfully declined the invitation.")
          end
        end

        context "when the user is signed in but not invited" do
          before do
            sign_in user, scope: :user
            get :decline_invitation, params:
          end

          it "does not decline any invitation" do
            expect(response).to redirect_to(root_path)
            expect(flash[:alert]).to be_present
          end
        end

        context "when the user is not signed in" do
          let!(:invite) { create(:conference_invite, conference:, user:, registration_type:) }

          before { get :decline_invitation, params: }

          it "does not decline the invitation and redirects to sign in" do
            expect(invite.reload.rejected_at).to be_nil
            expect(response).to redirect_to(new_user_session_path)
            expect(flash[:alert]).to eq("You need to log in before declining the invitation.")
          end
        end
      end
    end
  end
end
