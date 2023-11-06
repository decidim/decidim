# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe PushNotificationPresenter, type: :presenter do
    let(:notification) { create(:notification) }

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

      describe "#url" do
        it "returns the url to the comment" do
          # comment urls are anchors from the resource page to the comment
          expect(subject.url).to include("#comment_#{extra[:comment_id]}")
        end
      end
    end

    context "when it is a blog post" do
      let(:event_class) { Decidim::Blogs::CreatePostEvent }
      let(:event_name) { "decidim.events.blogs.post_created" }
      let(:resource) { create(:post) }
      let(:notification) { create(:notification, event_class:, event_name:, resource:) }

      describe "#body" do
        it "returns text without links and with HTML entities unescaped" do
          expect(subject.body).to eq("The post #{translated(resource.title)} has been published in #{translated(resource.component.participatory_space.title)}")
        end
      end

      describe "#url" do
        it "returns the url to the post" do
          expect(subject.url).to eq(resource_locator(resource).url)
        end
      end
    end
  end
end
