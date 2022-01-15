# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Comments
    describe CommentByFollowedUserEvent do
      include_context "when it's a comment event"
      let(:author) { comment.author }
      let(:resource) { comment.root_commentable }
      let(:event_name) { "decidim.events.comments.comment_by_followed_user" }

      it_behaves_like "a comment event"
      it_behaves_like "a translated comment event" do
        let(:translatable) { true }
      end

      describe "email_subject" do
        it "is generated correctly" do
          expect(subject.email_subject).to eq("There is a new comment by #{author_name} in #{resource_title}")
        end
      end

      describe "email_intro" do
        it "is generated correctly" do
          expect(subject.email_intro)
            .to eq("#{author_name} has left a comment in #{resource_title}. You can read it in this page:")
        end
      end

      describe "email_outro" do
        it "is generated correctly" do
          expect(subject.email_outro)
            .to include("You have received this notification because you are following #{author_name}")
        end
      end

      describe "notification_title" do
        it "is generated correctly" do
          expect(subject.notification_title)
            .to start_with("There is a new comment by <a href=\"#{author_path}\">#{author_name} #{author_nickname}</a> in")
          expect(subject.notification_title)
            .to end_with("<a href=\"#{resource_path}?commentId=#{comment.id}#comment_#{comment.id}\">#{resource_title}</a>.")
        end
      end
    end
  end
end
