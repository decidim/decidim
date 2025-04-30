# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Decidim::Devise::RegistrationsController do
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
            tos_agreement: "1",
            newsletter: "0"
          }
        }
      end

      context "when the user created is active for authentication" do
        before do
          expect_any_instance_of(Decidim::User) # rubocop:disable RSpec/AnyInstance
            .to receive(:active_for_authentication?)
            .at_least(:once)
            .and_return(true)
          expect(controller).to receive(:sign_up).and_call_original
        end

        it "does not ask the user to confirm the email" do
          post(:create, params:)
          expect(controller.flash.notice).to have_no_content("confirmation")
        end
      end

      context "when the form is invalid" do
        let(:email) { nil }

        it "renders the new template" do
          post(:create, params:)
          expect(controller).to render_template "new"
        end

        it "adds the flash message" do
          post(:create, params:)
          expect(controller.flash.now[:alert]).to have_content("There was a problem creating your account.")
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
                tos_agreement: "0",
                newsletter: "0"
              }
            }
          end

          it "adds the flash message" do
            post(:create, params:)
            expect(controller.flash.now[:alert]).to have_content("There was a problem creating your account.")
          end
        end
      end

      context "when the registering user has pending invitations" do
        let(:user) { create(:user, organization:, email:) }

        before do
          user.invite!
        end

        it "informs the user she must accept the pending invitation" do
          post(:create, params:)
          expect(controller).to render_template "new"
          expect(controller.flash.now[:alert]).to have_content("There was a problem creating your account.")
        end
      end
    end
  end
end
