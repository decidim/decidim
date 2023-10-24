# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe UpdatePassword do
    let(:command) { described_class.new(user, form) }
    let(:user) { create(:user, :confirmed, password_updated_at: 1.week.ago) }
    let(:password) { "updatedP4ssw0rd123456789" }
    let(:form) { Decidim::PasswordForm.from_params(password:) }

    context "when invalid" do
      let(:password) { "" }

      it "broadcasts invalid" do
        expect { command.call }.to broadcast(:invalid)
      end
    end

    context "when valid" do
      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok)
      end

      it "updates the users's password" do
        expect { command.call }.to change(user, :password)
      end

      it "sets the password_updated_at to the current time" do
        expect { command.call }.to broadcast(:ok)
        expect(user.reload.password_updated_at).to be_between(2.seconds.ago, Time.current)
      end
    end
  end
end
