# frozen_string_literal: true

require "spec_helper"

describe Decidim::Comments::UserMentionedEvent do
  include_context "when it's a comment event"

  let(:organization) { create(:organization) }

  let(:event_name) { "decidim.events.comments.user_mentioned" }
  let(:ca_comment_content) { "<div><p>Un commentaire pour #{author_link}</p></div>" }
  let(:en_comment_content) { "<div><p>Comment mentioning some user, #{author_link}</p></div>" }
  let(:author_link) { "<a class=\"user-mention\" href=\"http://#{organization.host}/profiles/#{author.nickname}\">@#{author.nickname}</a>" }
  let(:parsed_body) { Decidim::ContentProcessor.parse("Comment mentioning some user, @#{author.nickname}", current_organization: organization) }
  let(:parsed_ca_body) { Decidim::ContentProcessor.parse("Un commentaire pour @#{author.nickname}", current_organization: organization) }
  let(:body) { { en: parsed_body.rewrite, machine_translations: { ca: parsed_ca_body.rewrite } } }

  let(:participatory_process) { create :participatory_process, organization: }
  let(:component) { create(:component, participatory_space: participatory_process) }
  let(:commentable) { create(:dummy_resource, component:) }

  let(:author) { create :user, organization: }
  let!(:comment) { create :comment, body:, author:, commentable: }
  let(:user) { create :user, organization:, locale: "ca" }

  it_behaves_like "a comment event"

  describe "email_subject" do
    it "is generated correctly" do
      expect(subject.email_subject).to eq("You have been mentioned in #{translated resource.title}")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro).to eq("You have been mentioned")
    end
  end

  describe "email_outro" do
    it "is generated correctly" do
      expect(subject.email_outro)
        .to eq("You have received this notification because you have been mentioned in #{translated resource.title}.")
    end
  end

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title)
        .to include("You have been mentioned in <a href=\"#{resource_path}?commentId=#{comment.id}#comment_#{comment.id}\">#{translated resource.title}</a>")

      expect(subject.notification_title)
        .to include(" by <a href=\"/profiles/#{author.nickname}\">#{author.name} @#{author.nickname}</a>")
    end
  end

  describe "resource_text" do
    it "correctly renders comments with mentions" do
      expect(subject.resource_text).not_to include("gid://")
      expect(subject.resource_text).to include("@#{author.nickname}")
    end
  end

  describe "translated notifications" do
    let(:en_body) { parsed_body.rewrite }

    let(:body) { { en: en_body, machine_translations: { ca: parsed_ca_body.rewrite } } }

    let(:participatory_process) { create :participatory_process, organization: }
    let(:component) { create(:component, participatory_space: participatory_process) }
    let(:commentable) { create(:dummy_resource, component:) }
    let!(:comment) { create :comment, body:, author:, commentable: }
    let(:en_version) { en_comment_content }
    let(:machine_translated) { ca_comment_content }
    let(:translatable) { true }

    it_behaves_like "a translated event"
  end
end
