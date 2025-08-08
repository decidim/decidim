# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe UnsubscribeSettings do
    describe "call" do
      let(:organization) { create(:organization) }
      let(:command) { described_class.new(user) }

      context "when invalid" do
        let(:user) { create(:user, organization:, newsletter_notifications_at: nil) }

        it "Does not unsubscribe user" do
          expect { command.call }.to broadcast(:invalid)
        end
      end

      context "when valid" do
        let(:user) { create(:user, organization:, newsletter_notifications_at: Time.current) }

        it "unsubscribes user" do
          user.newsletter_notifications_at = nil
          user.save!

          user.reload
          expect(user.newsletter_notifications_at).to be_nil
        end

        it "broadcasts ok" do
          expect { command.call }.to broadcast(:ok)
        end
      end
    end
  end
end
