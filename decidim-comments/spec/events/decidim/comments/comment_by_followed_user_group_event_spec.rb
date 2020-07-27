# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Comments
    describe CommentByFollowedUserGroupEvent do
      include_context "when it's a comment event"
      let(:author) { comment.author }
      let(:resource) { comment.root_commentable }
      let(:event_name) { "decidim.events.comments.comment_by_followed_user_group" }
      let!(:user_group_author) { user_group }
      let(:user_group_path) { Decidim::UserGroupPresenter.new(user_group).profile_path }

      it_behaves_like "a comment event"

      describe "email_subject" do
        it "is correct" do
          expect(subject.email_subject).to eq("There is a new comment by #{CGI.escapeHTML(user_group.name)} in #{resource_title}")
        end
      end

      describe "email_intro" do
        it "is correct" do
          expect(subject.email_intro)
            .to eq("The group #{CGI.escapeHTML(user_group.name)} has left a comment in #{resource_title}. You can read it in this page:")
        end
      end

      describe "email_outro" do
        it "is correct" do
          expect(subject.email_outro)
            .to include("You have received this notification because you are following #{CGI.escapeHTML(user_group.name)}")
        end
      end

      describe "notification_title" do
        it "is correct" do
          expect(subject.notification_title)
            .to start_with("There is a new comment by <a href=\"#{user_group_path}\">#{CGI.escapeHTML(user_group.name)} @#{user_group.nickname}</a> in")
          expect(subject.notification_title)
            .to end_with("<a href=\"#{resource_path}#comment_#{comment.id}\">#{resource_title}</a>.")
        end
      end
    end
  end
end
