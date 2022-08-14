# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe UpdatePassword do
    subject { described_class.new(user, form) }

    let(:command) { described_class.new(user, form) }
    let(:user) { create(:user) }
    let(:form) do
      double(
        password:,
        password_confirmation: password,
        invalid?: invalid
      )
    end
    let(:password) { "decidim111222" }
    let(:invalid) { false }

    context "when invalid" do
      let(:invalid) { true }

      it "broadcasts invalid" do
        expect { command.call }.to broadcast(:invalid)
      end
    end

    context "when valid" do
      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok)
      end

      it "updates the users's password" do
        original_password = user.encrypted_password
        command.call
        user.reload
        expect(user.encrypted_password).not_to eq(original_password)
      end

      context "and the password has errors" do
        let(:password) { "short" }

        it "broadcasts invalid" do
          expect { command.call }.to broadcast(:invalid)
        end
      end
    end
  end
end
