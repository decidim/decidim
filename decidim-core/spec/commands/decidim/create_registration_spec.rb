# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Comments
    describe CreateRegistration do
      describe "call" do
        let(:organization) { create(:organization) }

        let(:sign_up_as) { "user" }
        let(:name) { "Username" }
        let(:email) { "user@example.org" }
        let(:password) { "password1234" }
        let(:password_confirmation) { password }
        let(:tos_agreement) { "1" }
        let(:newsletter_notifications) { "1" }

        let(:user_group_name) { "My organization" }
        let(:user_group_document_number) { "123456789Z" }
        let(:user_group_phone) { "333-333-333" }

        let(:form_params) do
          {
            "user" => {
              "sign_up_as" => sign_up_as,
              "name" => name,
              "email" => email,
              "password" => password,
              "password_confirmation" => password_confirmation,
              "tos_agreement" => tos_agreement,
              "newsletter_notifications" => newsletter_notifications,
              "user_group_name" => user_group_name,
              "user_group_document_number" => user_group_document_number,
              "user_group_phone" => user_group_phone
            }
          }
        end
        let(:form) do
          RegistrationForm.from_params(
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

          it "doesn't create a user" do
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
            expect(User).to receive(:create!).with(
              name: form.name,
              email: form.email,
              password: form.password,
              password_confirmation: form.password_confirmation,
              tos_agreement: form.tos_agreement,
              newsletter_notifications: form.newsletter_notifications,
              organization: organization
            ).and_call_original

            expect { command.call }.to change { User.count }.by(1)
          end
        end

        describe "when the user is signing up as a user group" do
          let(:sign_up_as) { "user_group" }

          let(:user_group_name) { "My organization" }
          let(:user_group_document_number) { "123456789Z" }
          let(:user_group_phone) { "333-333-333" }
          let(:user_group_decidim_organization_id) { organization.id }

          describe "when the form is not valid" do
            before do
              expect(form).to receive(:invalid?).and_return(true)
            end

            it "broadcasts invalid" do
              expect { command.call }.to broadcast(:invalid)
            end

            it "doesn't create a user group" do
              expect { command.call }.not_to change { UserGroup.count }
            end
          end

          describe "when the form is valid" do
            it "broadcasts ok" do
              expect { command.call }.to broadcast(:ok)
            end

            it "creates a new user group" do
              expect(UserGroup).to receive(:new).with(
                name: form.user_group_name,
                document_number: form.user_group_document_number,
                phone: form.user_group_phone,
                decidim_organization_id: organization.id
              ).and_call_original

              expect do
                command.call
                expect(UserGroup.last.users.first).to eq(User.last)
              end.to change { UserGroup.count }.by(1)
            end
          end
        end
      end
    end
  end
end
