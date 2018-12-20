# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Comments
    describe CommentByFollowedUserEvent do
      include Decidim::ComponentPathHelper

      include_context "when a simple event"

      let(:event_name) { "decidim.events.comments.comment_by_followed_user" }
      let(:comment) { create(:comment) }
      let(:resource) { comment.root_commentable }
      let(:resource_title) { resource.title }
      let(:extra) { { comment_id: comment.id } }
      let(:author) { comment.author }
      let(:author_name) { author.name }
      let(:author_path) { author_presenter&.profile_path.to_s }
      let(:author_nickname) { author_presenter&.nickname.to_s }

      it_behaves_like "a simple event"

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
            .to end_with("<a href=\"#{resource_path}#comment_#{comment.id}\">#{resource_title}</a>.")
        end
      end

      describe "resource_text" do
        it "outputs the comment body" do
          expect(subject.resource_text).to eq comment.body
        end
      end
    end
  end
end
