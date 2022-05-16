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
              "nickname" => "facebook_user",
              "oauth_signature" => oauth_signature,
              "avatar_url" => "http://www.example.com/foo.jpg"
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

        before do
          stub_request(:get, "http://www.example.com/foo.jpg")
            .to_return(status: 200, body: File.read("spec/assets/avatar.jpg"), headers: { "Content-Type" => "image/jpeg" })
        end

        describe "when the form oauth_signature cannot ve verified" do
          let(:oauth_signature) { "1234" }

          it "raises a InvalidOauthSignature exception" do
            expect { command.call }.to raise_error InvalidOauthSignature
          end
        end

        context "when the form is not valid" do
          before do
            allow(form).to receive(:invalid?).and_return(true)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't create a user" do
            expect do
              command.call
            end.not_to change(User, :count)
          end
        end

        context "when the form is valid" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "creates a new user" do
            allow(SecureRandom).to receive(:hex).and_return("decidim123456")

            expect do
              command.call
            end.to change(User, :count).by(1)

            user = User.find_by(email: form.email)
            expect(user.encrypted_password).not_to be_nil
            expect(user.email).to eq(form.email)
            expect(user.organization).to eq(organization)
            expect(user.newsletter_notifications_at).to be_nil
            expect(user).to be_confirmed
            expect(user.valid_password?("decidim123456")).to be(true)
          end

          it "notifies about registration with oauth data" do
            user = create(:user, email: email, organization: organization)
            identity = Decidim::Identity.new(id: 1234)
            allow(command).to receive(:create_identity).and_return(identity)

            expect(ActiveSupport::Notifications)
              .to receive(:publish)
              .with(
                "decidim.user.omniauth_registration",
                user_id: user.id,
                identity_id: 1234,
                provider: provider,
                uid: uid,
                email: email,
                name: "Facebook User",
                nickname: "facebook_user",
                avatar_url: "http://www.example.com/foo.jpg",
                raw_data: {}
              )
            command.call
          end

          describe "user linking" do
            context "with a verified email" do
              let(:verified_email) { email }

              it "links a previously existing user" do
                user = create(:user, email: email, organization: organization)
                expect { command.call }.to change(User, :count).by(0)

                expect(user.identities.length).to eq(1)
              end

              it "confirms a previously existing user" do
                create(:user, email: email, organization: organization)
                expect { command.call }.to change(User, :count).by(0)

                user = User.find_by(email: email)
                expect(user).to be_confirmed
              end
            end

            context "with an unverified email" do
              let(:verified_email) { nil }

              it "doesn't link a previously existing user" do
                user = create(:user, email: email, organization: organization)
                expect { command.call }.to broadcast(:error)

                expect(user.identities.length).to eq(0)
              end

              it "doesn't confirm a previously existing user" do
                create(:user, email: email, organization: organization)
                expect { command.call }.to broadcast(:error)

                user = User.find_by(email: email)
                expect(user).not_to be_confirmed
              end
            end
          end

          it "creates a new identity" do
            expect do
              command.call
            end.to change(Identity, :count).by(1)
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

        context "when a user exists with that identity" do
          before do
            user = create(:user, email: email, organization: organization)
            create(:identity, user: user, provider: provider, uid: uid)
          end

          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          context "with the same email as reported by the identity" do
            it "confirms the user" do
              command.call

              user = User.find_by(email: email)
              expect(user).to be_confirmed
            end
          end

          context "with another email than in the one reported by the identity" do
            let(:verified_email) { "other@email.com" }

            it "doesn't confirm the user" do
              command.call

              user = User.find_by(email: email)
              expect(user).not_to be_confirmed
            end
          end
        end
      end
    end
  end
end
