# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Decidim::Devise::OmniauthRegistrationsController do
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

      describe "after_sign_in_path_for" do
        subject { controller.after_sign_in_path_for(user) }

        before do
          request.env["decidim.current_organization"] = user.organization
        end

        context "when the given resource is a user" do
          context "and is an admin" do
            let(:user) { build(:user, :admin, sign_in_count: 1) }

            before do
              controller.store_location_for(user, account_path)
            end

            it { is_expected.to eq account_path }
          end

          context "and is not an admin" do
            context "when it is the first time to log in" do
              let(:user) { build(:user, :confirmed, sign_in_count: 1) }

              context "when there are authorization handlers" do
                before do
                  allow(user.organization).to receive(:available_authorizations)
                    .and_return(["dummy_authorization_handler"])
                end

                it { is_expected.to eq("/authorizations/first_login") }

                context "when there is a pending redirection" do
                  before do
                    controller.store_location_for(user, account_path)
                  end

                  it { is_expected.to eq account_path }
                end

                context "when the user has not confirmed their email" do
                  before do
                    user.confirmed_at = nil
                  end

                  it { is_expected.to eq("/") }
                end

                context "when the user is blocked" do
                  before do
                    user.blocked = true
                  end

                  it { is_expected.to eq("/") }
                end

                context "when the user is not blocked" do
                  before do
                    user.blocked = false
                  end

                  it { is_expected.to eq("/authorizations/first_login") }
                end
              end

              context "and otherwise", with_authorization_workflows: [] do
                before do
                  allow(user.organization).to receive(:available_authorizations).and_return([])
                end

                it { is_expected.to eq("/") }
              end
            end

            context "and it is not the first time to log in" do
              let(:user) { build(:user, sign_in_count: 2) }

              it { is_expected.to eq("/") }
            end
          end
        end
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

        it "does not create a new user" do
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
            request.env["omniauth.auth"][:info][:email] = "omniauth@example.com"
          end

          it "does not log in" do
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
