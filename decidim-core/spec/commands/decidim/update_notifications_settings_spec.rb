require "spec_helper"

module Decidim
  describe UpdateNotificationsSettings do
    let(:command) { described_class.new(user, form) }
    let(:user) { create(:user) }
    let(:valid) { true }
    let(:data) do
      {
        comments_notifications: "1",
        replies_notifications: "0"
      }
    end

    let(:form) do
      form = double(
        comments_notifications: data[:comments_notifications],
        replies_notifications: data[:replies_notifications],
        valid?: valid
      )

      form
    end

    context "when invalid" do
      let(:valid) { false }

      it "Doesn't update anything" do
        expect { command.call }.to broadcast(:invalid)
        expect(user.reload.replies_notifications).to be_truthy
      end
    end

    context "when valid" do
      let(:valid) { true }

      it "updates the users's notifications settings" do
        expect { command.call }.to broadcast(:ok)
        expect(user.reload.replies_notifications).to be_falsy
      end
    end
  end
end
