# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Decidim::Devise::OmniauthRegistrationsController, type: :controller do
    routes { Decidim::Core::Engine.routes }

    let(:organization) { create(:organization) }

    before do
      request.env["decidim.current_organization"] = organization
      request.env["devise.mapping"] = ::Devise.mappings[:user]
    end

    describe "POST create" do
      let(:provider) { "facebook" }
      let(:uid) { "12345" }
      let(:email) { "user@from-facebook.com" }
      let!(:user) { create(:user, organization:, email:) }

      before do
        request.env["omniauth.auth"] = {
          provider:,
          uid:,
          info: {
            name: "Facebook User",
            nickname: "facebook_user",
            email:
          }
        }
      end

      context "when the user has the account blocked" do
        let!(:user) { create(:user, organization:, email:, blocked: true) }

        before do
          post :create
        end

        it "logs in" do
          expect(controller).not_to be_user_signed_in
        end

        it "redirects to root" do
          expect(controller).to redirect_to(root_path)
        end

        it "shows an error message instead of notice" do
          expect(flash[:error]).to be_present
        end
      end

      context "when the unverified email address is already in use" do
        before do
          post :create
        end

        it "doesn't create a new user" do
          expect(User.count).to eq(1)
        end

        it "logs in" do
          expect(controller).to be_user_signed_in
        end
      end

      context "when the unverified email address is already in use but left unconfirmed" do
        before do
          user.update!(
            confirmation_sent_at: Time.now.utc - 1.year
          )
        end

        context "with the same email as from the identity provider" do
          before do
            post :create
          end

          it "logs in" do
            expect(controller).to be_user_signed_in
          end

          it "confirms the user account" do
            expect(controller.current_user).to be_confirmed
          end
        end

        context "with another email than the one from the identity provider" do
          let!(:identity) { create(:identity, user:, uid:) }

          before do
            request.env["omniauth.auth"][:info][:email] = "omniauth@email.com"
          end

          it "doesn't log in" do
            post :create

            expect(controller).not_to be_user_signed_in
          end

          it "resends the confirmation instructions" do
            expect(Decidim::DecidimDeviseMailer).to receive(:confirmation_instructions).and_call_original

            expect do
              post :create
            end.to have_enqueued_job(ActionMailer::MailDeliveryJob).with(
              "Decidim::DecidimDeviseMailer",
              "confirmation_instructions",
              "deliver_now",
              { args: [user, kind_of(String), {}] }
            )
          end

          it "redirects to root" do
            post :create

            expect(controller).to redirect_to(root_path)
          end
        end
      end
    end
  end
end
