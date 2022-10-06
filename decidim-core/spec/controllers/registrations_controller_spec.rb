# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Decidim::Devise::RegistrationsController, type: :controller do
    routes { Decidim::Core::Engine.routes }

    let(:organization) { create(:organization) }
    let(:email) { "test@example.org" }

    before do
      request.env["devise.mapping"] = ::Devise.mappings[:user]
      request.env["decidim.current_organization"] = organization
    end

    describe "POST create" do
      let(:params) do
        {
          user: {
            sign_up_as: "user",
            name: "User",
            nickname: "nickname",
            email:,
            password: "rPYWYKQJrXm97b4ytswc",
            password_confirmation: "rPYWYKQJrXm97b4ytswc",
            tos_agreement: "1",
            newsletter: "0"
          }
        }
      end

      def send_form_and_expect_rendering_the_new_template_again
        post :create, params: params
        expect(controller).to render_template "new"
      end

      context "when the user created is active for authentication" do
        before do
          expect_any_instance_of(Decidim::User) # rubocop:disable RSpec/AnyInstance
            .to receive(:active_for_authentication?)
            .at_least(:once)
            .and_return(true)
          expect(controller).to receive(:sign_up).and_call_original
        end

        it "doesn't ask the user to confirm the email" do
          post :create, params: params
          expect(controller.flash.notice).not_to have_content("confirmation")
        end
      end

      context "when the form is invalid" do
        let(:email) { nil }

        it "renders the new template" do
          send_form_and_expect_rendering_the_new_template_again
        end

        it "adds the flash message" do
          post :create, params: params
          expect(controller.flash.now[:alert]).to have_content("Your email can't be blank")
        end

        context "when all params are invalid" do
          let(:params) do
            {
              user: {
                sign_up_as: "",
                name: "",
                nickname: "",
                email:,
                password: "123",
                password_confirmation: "456",
                tos_agreement: "0",
                newsletter: "0"
              }
            }
          end

          it "adds the flash message" do
            post :create, params: params
            expect(controller.flash.now[:alert]).to have_content(
              [
                "Your name can't be blank",
                "Nickname can't be blank",
                "Nickname is invalid",
                "Your email can't be blank",
                "Confirm your password doesn't match Password",
                "Password is too short",
                "Password does not have enough unique characters",
                "Tos agreement must be accepted"
              ].join(", ")
            )
          end
        end
      end

      context "when the registering user has pending invitations" do
        let(:user) { create(:user, organization:, email:) }

        before do
          user.invite!
        end

        it "informs the user she must accept the pending invitation" do
          send_form_and_expect_rendering_the_new_template_again
          expect(controller.flash.now[:alert]).to have_content("You have a pending invitation, accept it to finish creating your account")
        end
      end
    end
  end
end
