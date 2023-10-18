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
        original_password = user.encrypted_password
        expect { command.call }.to change(user, :password)
        user.reload
        expect(user.encrypted_password).not_to eq(original_password)
      end

      it "sets the password_updated_at to the current time" do
        expect { command.call }.to broadcast(:ok)
        expect(user.reload.password_updated_at).to be_between(2.seconds.ago, Time.current)
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
