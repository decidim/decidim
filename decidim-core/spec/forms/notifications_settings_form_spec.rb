require "spec_helper"

module Decidim
  describe NotificationsSettingsForm do
    let(:user) { create(:user) }

    let(:comments_notifications) { "1" }
    let(:replies_notifications) { "1" }
    let(:newsletter_notifications) { "1" }

    subject do
      described_class.new(
        comments_notifications: comments_notifications,
        replies_notifications: replies_notifications,
        newsletter_notifications: newsletter_notifications
      ).with_context(
        current_user: user
      )
    end

    context "with correct data" do
      it "is valid" do
        expect(subject).to be_valid
      end
    end

    context "with an empty comments notifications" do
      let(:comments_notifications) { "" }

      it "is invalid" do
        expect(subject).not_to be_valid
      end
    end

    context "with an empty replies notifications" do
      let(:replies_notifications) { "" }

      it "is invalid" do
        expect(subject).not_to be_valid
      end
    end

    context "with an empty newsletter notifications" do
      let(:newsletter_notifications) { "" }

      it "is invalid" do
        expect(subject).not_to be_valid
      end
    end
  end
end
