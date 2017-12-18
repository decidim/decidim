# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe UnsubscribeSettings do
    describe "call" do
      let(:organization) { create(:organization) }
      let(:command) { described_class.new(user) }

      describe "when user click to unsubscribe" do
        describe "when user newsletter_notifications are true" do
          let(:user) { create(:user, organization: organization, newsletter_notifications: "1") }

          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "unsubscribes user" do
            user.newsletter_notifications = "0"
            user.save!
          end
        end

        describe "when user newsletter_notifications are false" do
          let(:user) { create(:user, organization: organization, newsletter_notifications: "0") }

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end
        end
      end
    end
  end
end
