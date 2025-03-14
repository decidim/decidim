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
        let(:tos_agreement) { true }
        let(:nickname) { "facebook_user" }
        let(:form_params) do
          {
            "user" => {
              "provider" => provider,
              "uid" => uid,
              "email" => email,
              "email_verified" => true,
              "name" => "Facebook User",
              "nickname" => nickname,
              "oauth_signature" => oauth_signature,
              "avatar_url" => "http://www.example.com/foo.jpg",
              "tos_agreement" => tos_agreement
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

        describe "when the User name has invalid characters" do
          let(:test_email) { "test_user@from-facebook.com" }
          let(:test_form_params) do
            {
              "user" => {
                "provider" => provider,
                "uid" => uid,
                "email" => test_email,
                "email_verified" => true,
                "name" => "Facebook# User",
                "nickname" => "facebook_user",
                "oauth_signature" => oauth_signature,
                "avatar_url" => "http://www.example.com/foo.jpg",
                "tos_agreement" => tos_agreement
              }
            }
          end

          let(:test_form) do
            OmniauthRegistrationForm.from_params(
              test_form_params
            ).with_context(
              current_organization: organization
            )
          end
          let(:command) { described_class.new(test_form, test_email) }

          it "sanitizes the name" do
            allow(SecureRandom).to receive(:hex).and_return("decidim123456789")

            expect do
              command.call
            end.to change(User, :count).by(1)

            user = User.find_by(email: test_form.email)
            expect(user.email).to eq(test_form.email)
            expect(user.name).to eq("Facebook User")
          end
        end

        context "when the form is not valid" do
          before do
            allow(form).to receive(:invalid?).and_return(true)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "does not create a user" do
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
            allow(SecureRandom).to receive(:hex).and_return("decidim123456789")

            expect do
              command.call
            end.to change(User, :count).by(1)

            user = User.find_by(email: form.email)
            expect(user.encrypted_password).not_to be_nil
            expect(user.email).to eq(form.email)
            expect(user.organization).to eq(organization)
            expect(user.newsletter_notifications_at).to be_nil
            expect(user).to be_confirmed
            expect(user.valid_password?("decidim123456789")).to be(true)
          end

          it "download and attach the avatar" do
            stub_request(:get, "http://www.example.com/foo.jpg").to_return(
              status: 200,
              body: File.read("spec/assets/avatar.jpg"), headers: { "Content-Type" => "image/jpeg" }
            )
            expect { command.call }.to broadcast(:ok)
            user = User.find_by(email: form.email)
            expect(user.avatar).to be_attached
            expect(user.avatar.attachment.filename.to_s).to eq("foo.jpg")
            expect(user.avatar.attachment.blob.byte_size).to eq(File.open("spec/assets/avatar.jpg").size)
          end

          context "when avatar URL fetching fails" do
            it "with a 404 HTTP code, it saves the user without avatar" do
              stub_request(:get, "http://www.example.com/foo.jpg").to_return(status: 404)
              expect { command.call }.to broadcast(:ok)
              user = User.find_by(email: form.email)
              expect(user.avatar).not_to be_attached
            end

            it "with a 502 HTTP code, it saves the user without avatar" do
              stub_request(:get, "http://www.example.com/foo.jpg").to_return(status: 502)
              expect { command.call }.to broadcast(:ok)
              user = User.find_by(email: form.email)
              expect(user.avatar).not_to be_attached
            end

            it "with a 500 HTTP code, it saves the user without avatar" do
              stub_request(:get, "http://www.example.com/foo.jpg").to_return(status: 500)
              expect { command.call }.to broadcast(:ok)
              user = User.find_by(email: form.email)
              expect(user.avatar).not_to be_attached
            end

            it "with a 401 HTTP code, it saves the user without avatar" do
              stub_request(:get, "http://www.example.com/foo.jpg").to_return(status: 401)
              expect { command.call }.to broadcast(:ok)
              user = User.find_by(email: form.email)
              expect(user.avatar).not_to be_attached
            end
          end

          # NOTE: This is important so that the users who are only
          # authenticating using omniauth will not need to update their
          # passwords.
          it "leaves password_updated_at nil" do
            expect { command.call }.to broadcast(:ok)

            user = User.find_by(email: form.email)
            expect(user.password_updated_at).to be_nil
          end

          it "notifies about registration with oauth data" do
            user = create(:user, email:, organization:)
            identity = Decidim::Identity.new(id: 1234)
            allow(command).to receive(:create_identity).and_return(identity)

            expect(ActiveSupport::Notifications)
              .to receive(:publish)
              .with("decidim.events.core.welcome_notification",
                    affected_users: [user],
                    event_class: "Decidim::WelcomeNotificationEvent",
                    extra: { force_email: true },
                    followers: [],
                    force_send: false,
                    resource: user)

            expect(ActiveSupport::Notifications)
              .to receive(:publish)
              .with(
                "decidim.user.omniauth_registration",
                user_id: user.id,
                identity_id: 1234,
                provider:,
                uid:,
                email:,
                name: "Facebook User",
                nickname: "facebook_user",
                avatar_url: "http://www.example.com/foo.jpg",
                raw_data: {},
                tos_agreement: true,
                accepted_tos_version: user.accepted_tos_version,
                newsletter_notifications_at: user.newsletter_notifications_at
              )
            command.call
          end

          describe "user linking" do
            context "with a verified email" do
              let(:verified_email) { email }

              it "links a previously existing user" do
                user = create(:user, email:, organization:)
                expect { command.call }.not_to change(User, :count)
                expect(user.identities.length).to eq(1)
              end

              it "confirms a previously existing user" do
                create(:user, email:, organization:)
                expect { command.call }.not_to change(User, :count)

                user = User.find_by(email:)
                expect(user).to be_confirmed
              end
            end

            context "with an unverified email" do
              let(:verified_email) { nil }

              it "does not link a previously existing user" do
                user = create(:user, email:, organization:)
                expect { command.call }.to broadcast(:error)

                expect(user.identities.length).to eq(0)
              end

              it "does not confirm a previously existing user" do
                create(:user, email:, organization:)
                expect { command.call }.to broadcast(:error)

                user = User.find_by(email:)
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

        context "when the nickname has capital letters" do
          let(:nickname) { "Facebook_user" }

          it "downcases the nickname" do
            command.call

            user = User.where(email:).last
            expect(user.nickname).to eq("facebook_user")
          end
        end

        context "when a user exists with that identity" do
          before do
            user = create(:user, email:, organization:)
            create(:identity, user:, provider:, uid:)
          end

          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          context "with the same email as reported by the identity" do
            it "confirms the user" do
              command.call

              user = User.find_by(email:)
              expect(user).to be_confirmed
            end
          end

          context "with another email than in the one reported by the identity" do
            let(:verified_email) { "other@example.com" }

            it "does not confirm the user" do
              command.call

              user = User.find_by(email:)
              expect(user).not_to be_confirmed
            end
          end
        end
      end
    end
  end
end
