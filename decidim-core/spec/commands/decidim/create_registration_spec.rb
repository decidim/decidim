# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Comments
    describe CreateRegistration do
      describe "call" do
        let(:organization) { create(:organization) }

        let(:name) { "Username" }
        let(:email) { "user@example.org" }
        let(:password) { "Y1fERVzL2F" }
        let(:tos_agreement) { "1" }
        let(:newsletter) { "1" }
        let(:current_locale) { "es" }

        let(:form_params) do
          {
            "user" => {
              "name" => name,
              "email" => email,
              "password" => password,
              "tos_agreement" => tos_agreement,
              "newsletter_at" => newsletter
            }
          }
        end
        let(:form) do
          RegistrationForm.from_params(
            form_params,
            current_locale:
          ).with_context(
            current_organization: organization
          )
        end
        let(:command) { described_class.new(form) }

        describe "when the form is not valid" do
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

          context "when the user was already invited" do
            let(:user) { build(:user, email:, organization:) }

            before do
              user.invite!
              clear_enqueued_jobs
            end

            it "receives the invitation email again" do
              expect { command.call }.not_to change(User, :count)
              expect do
                command.call
                user.reload
              end.to broadcast(:invalid)
                .and change(user.reload, :invitation_token)
              expect(ActionMailer::MailDeliveryJob).to have_been_enqueued.on_queue("mailers").twice
            end
          end
        end

        describe "when the form is valid" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "creates a new user" do
            expect(User).to receive(:create!).with(
              name: form.name,
              nickname: form.nickname,
              email: form.email,
              password: form.password,
              password_updated_at: an_instance_of(ActiveSupport::TimeWithZone),
              tos_agreement: form.tos_agreement,
              newsletter_notifications_at: form.newsletter_at,
              organization:,
              accepted_tos_version: organization.tos_version,
              locale: form.current_locale
            ).and_call_original

            expect { command.call }.to change(User, :count).by(1)
          end

          context "when name is Capitalized" do
            let(:name) { "Username" }

            it "downcases generated user nickname" do
              expect(User).to receive(:create!).with(
                name: form.name,
                nickname: "username",
                email: form.email,
                password: form.password,
                password_updated_at: an_instance_of(ActiveSupport::TimeWithZone),
                tos_agreement: form.tos_agreement,
                newsletter_notifications_at: form.newsletter_at,
                organization:,
                accepted_tos_version: organization.tos_version,
                locale: form.current_locale
              ).and_call_original

              expect { command.call }.to change(User, :count).by(1)
            end
          end

          it "sets the password_updated_at to the current time" do
            expect { command.call }.to broadcast(:ok)
            expect(User.last.password_updated_at).to be_between(2.seconds.ago, Time.current)
          end

          describe "when user keeps the newsletter unchecked" do
            let(:newsletter) { "0" }

            it "creates a user with no newsletter notifications" do
              expect do
                command.call
                expect(User.last.newsletter_notifications_at).to be_nil
              end.to change(User, :count).by(1)
            end
          end
        end
      end
    end
  end
end
