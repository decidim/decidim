# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Comments
    describe CreateOmniauthRegistration do
      describe "call" do
        let(:organization) { create(:organization) }
        let(:email) { "user@from-facebook.com" }
        let(:provider) { "facebook" }
        let(:uid) { "12345" }
        let(:oauth_signature) { OmniauthRegistrationForm.create_signature(provider, uid) }
        let(:verified_email) { email }
        let(:form_params) do
          {
            "user" => {
              "provider" => provider,
              "uid" => uid,
              "email" => email,
              "email_verified" => true,
              "name" => "Facebook User",
              "oauth_signature" => oauth_signature
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
        let(:command) { described_class.new(form, verified_email) }

        describe "when the form oauth_signature cannot ve verified" do
          let(:oauth_signature) { "1234" }

          it "raises a InvalidOauthSignature exception" do
            expect { command.call }.to raise_error InvalidOauthSignature
          end
        end

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
            end.not_to change { User.count }
          end
        end

        describe "when the form is valid" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "creates a new user" do
            expect(SecureRandom).to receive(:hex).and_return("abcde1234")

            expect do
              command.call
            end.to change { User.count }.by(1)

            user = User.find_by(email: form.email)
            expect(user.encrypted_password).not_to be_nil
            expect(user.email).to eq(form.email)
            expect(user.organization).to eq(organization)
            expect(user).to be_confirmed
            expect(user.valid_password?("abcde1234")).to eq(true)
          end

          describe "user linking" do
            context "with a verified email" do
              let(:verified_email) { email }

              it "links a previously existing user" do
                user = create(:user, email: email, organization: organization)
                expect { command.call }.to change { User.count }.by(0)

                expect(user.identities.length).to eq(1)
              end
            end

            context "with an unverified email" do
              let(:verified_email) { nil }

              it "doesn't link a previously existing user" do
                user = create(:user, email: email, organization: organization)
                expect { command.call }.to broadcast(:error)

                expect(user.identities.length).to eq(0)
              end
            end
          end

          it "creates a new identity" do
            expect do
              command.call
            end.to change { Identity.count }.by(1)
            last_identity = Identity.last
            expect(last_identity.provider).to eq(form.provider)
            expect(last_identity.uid).to eq(form.uid)
            expect(last_identity.organization).to eq(organization)
          end

          it "confirms the user if the email is already verified" do
            # rubocop:disable RSpec/AnyInstance
            expect_any_instance_of(User).to receive(:skip_confirmation!)
            # rubocop:enable RSpec/AnyInstance
            command.call
          end
        end

        describe "when a user exists with that identity" do
          it "broadcasts ok" do
            user = create(:user, email: email, organization: organization)
            create(:identity, user: user, provider: provider, uid: uid)

            expect { command.call }.to broadcast(:ok)
          end
        end
      end
    end
  end
end
