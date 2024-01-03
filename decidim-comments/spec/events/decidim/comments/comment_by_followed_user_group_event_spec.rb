# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Comments
    describe CommentByFollowedUserGroupEvent do
      include_context "when it is a comment event"
      let(:author) { comment.author }
      let(:resource) { comment.root_commentable }
      let(:event_name) { "decidim.events.comments.comment_by_followed_user_group" }
      let!(:user_group_author) { user_group }
      let(:user_group_path) { Decidim::UserGroupPresenter.new(user_group).profile_path }
      let(:email_subject) { "There is a new comment by #{escaped_html(user_group.name)} in #{resource_title}" }
      let(:email_intro) { "The group #{escaped_html(user_group.name)} has left a comment in #{resource_title}. You can read it in this page:" }
      let(:email_outro) { "You have received this notification because you are following #{escaped_html(user_group.name)}. You can unfollow this group from its profile page." }
      let(:notification_title) { "There is a new comment by <a href=\"#{user_group_path}\">#{escaped_html(user_group.name)} @#{user_group.nickname}</a> in <a href=\"#{resource_path}?commentId=#{comment.id}#comment_#{comment.id}\">#{resource_title}</a>." }

      it_behaves_like "a simple event email"
      it_behaves_like "a simple event notification"
      it_behaves_like "a comment event"
      it_behaves_like "a translated comment event" do
        let(:translatable) { true }
      end
    end
  end
end
