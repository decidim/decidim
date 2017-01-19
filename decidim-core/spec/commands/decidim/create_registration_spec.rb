# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Comments
    describe CreateRegistration, :db do
      describe "call" do
        let(:organization) { create(:organization) }
        let(:name) { "Username" }
        let(:email) { "user@decidim.org" }
        let(:password) { "password1234" }
        let(:password_confirmation) { password }
        let(:tos_agreement) { "1" }
       
        let(:form_params) do
          {
            "user" => {
              "name" => name,
              "email" => email,
              "password" => password,
              "password_confirmation" => password_confirmation,
              "tos_agreement" => tos_agreement
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
            end.to_not change { User.count }
          end
        end

        describe "when the form is valid" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "creates a new user" do
            expect(User).to receive(:create!).with({
              name: form.name,
              email: form.email,
              password: form.password,
              password_confirmation: form.password_confirmation,
              tos_agreement: form.tos_agreement,
              organization: organization
            }).and_call_original
            expect do
              command.call
            end.to change { User.count }.by(1)
          end
        end
      end
    end
  end
end
