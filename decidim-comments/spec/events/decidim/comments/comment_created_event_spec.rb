# frozen_string_literal: true

require "spec_helper"

describe Decidim::Comments::CommentCreatedEvent do
  include_context "when it is a comment event"
  let(:event_name) { "decidim.events.comments.comment_created" }
  let(:email_subject) { "There is a new comment from #{comment_author.name} in #{resource_title}" }
  let(:email_intro) { "#{resource_title} has been commented. You can read the comment in this page:" }
  let(:email_outro) { "You have received this notification because you are following \"#{resource_title}\" or its author. You can unfollow it from the previous link." }
  let(:notification_title) { "There is a new comment from <a href=\"/profiles/#{comment_author.nickname}\">#{comment_author.name} @#{comment_author.nickname}</a> in <a href=\"#{resource_path}?commentId=#{comment.id}#comment_#{comment.id}\">#{resource_title}</a>" }

  it_behaves_like "a simple event email"
  it_behaves_like "a simple event notification"
  it_behaves_like "a comment event"
  it_behaves_like "a translated comment event" do
    let(:translatable) { true }
  end
end
