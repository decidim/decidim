# frozen_string_literal: true

require "spec_helper"

module Decidim
  module System
    describe CreateAdmin do
      describe "call" do
        let(:form) { AdminForm.new(params) }
        let(:command) { described_class.new(form) }

        describe "when the admin already exists" do
          before do
            create(:admin, email: "email@foo.bar")
          end

          let(:params) do
            {
              email: "email@foo.bar"
            }
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end
        end

        describe "when the password is too common" do
          before do
            create(:admin, email: "email@foo.bar")
          end

          let(:params) do
            {
              password: "password1234",
              password_confirmation: "password1234"
            }
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end
        end

        describe "when the admin doesn't exist" do
          before do
            create(:admin, email: "email@foo.bar")
          end

          let(:params) do
            {
              email: "different_email@foo.bar",
              password: "fake123456",
              password_confirmation: "fake123456"
            }
          end

          it "broadcasts ok and creates an admin" do
            expect { command.call }.to broadcast(:ok)
            expect(Admin.where(email: "different_email@foo.bar")).to exist
          end
        end
      end
    end
  end
end
