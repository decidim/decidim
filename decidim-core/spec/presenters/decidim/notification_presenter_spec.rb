# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe NotificationPresenter, type: :presenter do
    include ActiveSupport::Testing::TimeHelpers

    let(:creating_date) { Time.parse("Wed, 1 Sep 2021 21:00:00 UTC +00:00").in_time_zone }
    let(:notification) { create(:notification, created_at: creating_date) }

    subject { described_class.new(notification) }

    context "with a valid notification" do
      describe "#display_resource_text?" do
        it "returns false if the notification has not to display the content of the comment" do
          expect(subject.display_resource_text?).to be(false)
        end
      end
    end

    context "with a valid comment notification" do
      let(:event_class) { "Decidim::Comments::CommentCreatedEvent" }
      let(:event_name) { "decidim.events.comments.comment_created" }
      let(:extra) { { comment_id: create(:comment).id } }

      let(:notification) { create(:notification, event_class:, event_name:, extra:) }

      subject { described_class.new(notification) }

      describe "#display_resource_text?" do
        it "returns true if the notification has to display the content of the comment" do
          expect(subject.display_resource_text?).to be(true)
        end
      end
    end
  end
end
