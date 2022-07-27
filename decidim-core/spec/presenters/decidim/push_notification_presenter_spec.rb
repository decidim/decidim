# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe PushNotificationPresenter, type: :presenter do
    let(:notification) { create(:notification) }
    let(:np) { described_class.new(notification) }

    subject { described_class.new(notification) }

    context "with a valid notification" do
      let(:event_class) { Decidim::Comments::CommentCreatedEvent }
      let(:event_name) { "decidim.events.comments.comment_created" }
      let(:extra) { { comment_id: create(:comment).id } }

      let(:notification) { create(:notification, event_class:, event_name:, extra:) }

      describe "#body" do
        it "returns text without links and with HTML entities unescaped" do
          # rubocop:disable RSpec/AnyInstance
          allow_any_instance_of(event_class).to receive(:notification_title).and_return(
            "There is a new comment from <a href='/path/to/profile'>Foo & Bar 1 < 2 & 2 > 3</a>"
          )

          expect(subject.body).to eq("There is a new comment from Foo & Bar 1 < 2 & 2 > 3")
          # rubocop:enable RSpec/AnyInstance
        end
      end
    end
  end
end
