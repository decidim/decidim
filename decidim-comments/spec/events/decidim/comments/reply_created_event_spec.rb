# frozen_string_literal: true

require "spec_helper"

describe Decidim::Comments::ReplyCreatedEvent do
  include_context "when it is a comment event"
  let(:event_name) { "decidim.events.comments.reply_created" }
  let(:comment) { create(:comment, commentable: parent_comment, root_commentable: parent_comment.root_commentable) }
  let(:parent_comment) { create(:comment) }
  let(:resource) { comment.root_commentable }
  let(:email_subject) { "#{comment_author_name} has replied your comment in #{resource_title}" }
  let(:email_intro) { "#{comment_author_name} has replied your comment in #{resource_title}. You can read it in this page:" }
  let(:email_outro) { "You have received this notification because your comment was replied." }
  let(:notification_title) { "<a href=\"/profiles/#{comment_author.nickname}\">#{comment_author_name} @#{comment_author.nickname}</a> has replied your comment in <a href=\"#{resource_path}?commentId=#{comment.id}#comment_#{comment.id}\">#{resource_title}</a>" }

  it_behaves_like "a simple event email"
  it_behaves_like "a simple event notification"
  it_behaves_like "a comment event"
  it_behaves_like "a translated comment event" do
    let(:translatable) { true }
  end
end
