# frozen_string_literal: true

require "spec_helper"

describe Decidim::Comments::UserGroupMentionedEvent do
  include_context "when it's a comment event"

  let(:event_name) { "decidim.events.comments.user_group_mentioned" }

  let(:extra) do
    {
      comment_id: comment.id,
      group: group
    }
  end

  let(:group) { create :user_group, organization: comment.organization, users: [comment.author, member] }
  let(:member) { create :user, organization: comment.organization }

  before do
    body = "Comment mentioning some user group, @#{group.nickname}"
    parsed_body = Decidim::ContentProcessor.parse(body, current_organization: comment.organization)
    comment.body = { en: parsed_body.rewrite }
    comment.save
  end

  it_behaves_like "a comment event"

  describe "email_subject" do
    it "is generated correctly" do
      expect(subject.email_subject).to eq("You have been mentioned in #{translated resource.title} as a member of #{group.name}")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro).to eq("A group you belong to has been mentioned")
    end
  end

  describe "email_outro" do
    it "is generated correctly" do
      expect(subject.email_outro)
        .to eq("You have received this notification because you are a member of the group #{group.name} that has been mentioned in #{translated resource.title}.")
    end
  end

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title)
        .to include("You have been mentioned in <a href=\"#{resource_path}#comment_#{comment.id}\">#{translated resource.title}</a>")

      expect(subject.notification_title)
        .to include(" as a member of <a href=\"/profiles/#{group.nickname}\">#{group.name} @#{group.nickname}</a>")

      expect(subject.notification_title)
        .to include(" by <a href=\"/profiles/#{comment_author.nickname}\">#{comment_author.name} @#{comment_author.nickname}</a>")
    end
  end

  describe "resource_text" do
    it "correctly renders comments with mentions" do
      expect(subject.resource_text).not_to include("gid://")
      expect(subject.resource_text).to include("@#{group.nickname}")
    end
  end
end
