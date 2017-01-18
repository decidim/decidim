# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Comments
    describe CreateOmniauthRegistration, :db do
      describe "call" do
        let(:organization) { create(:organization) }
        let(:email) { "user@from-facebook.com" }
        let(:provider) { "facebook" }
        let(:uid) { "12345" }
        let(:form_params) do
          {
            "user" => {
              "provider" => provider,
              "uid" => uid,
              "email" => email,
              "email_verified" => true,
              "name" => "Facebook User",
              "tos_agreement" => true,
              "oauth_signature" => OmniauthRegistrationForm.create_signature(provider, uid)
            }
          }
        end
        let(:form) do
          OmniauthRegistrationForm.from_params(
            form_params
          ).with_context(
            current_organization: organization
          )
        end
        let(:command) { described_class.new(form) }

        describe "when the form is not valid" do
          before do
            expect(form).to receive(:invalid?).and_return(true)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't create a comment" do
            expect do
              command.call
            end.to_not change { User.count }
          end
        end

        describe "when the form is valid" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "creates a new user" do
            expect(SecureRandom).to receive(:hex).and_return("abcde1234")
            expect(User).to receive(:create!).with({
              email: form.email,
              name: form.name,
              password: "abcde1234",
              password_confirmation: "abcde1234",
              tos_agreement: form.tos_agreement,
              organization: organization
            }).and_call_original
            expect do
              command.call
            end.to change { User.count }.by(1)
          end

          it "creates a new identity" do
            expect do
              command.call
            end.to change { Identity.count }.by(1)
            last_identity = Identity.last
            expect(last_identity.provider).to eq(form.provider)
            expect(last_identity.uid).to eq(form.uid)
          end

          it "confirms the user if the email is already verified" do
            expect_any_instance_of(User).to receive(:skip_confirmation!)
            command.call
          end
        end

        describe "when the email is already used" do
          it "broadcasts error" do
            create(:user, email: email)
            expect { command.call }.to broadcast(:error)
          end
        end
      end
    end
  end
end
