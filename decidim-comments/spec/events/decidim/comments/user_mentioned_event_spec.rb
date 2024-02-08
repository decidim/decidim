# frozen_string_literal: true

require "spec_helper"

describe Decidim::Comments::UserMentionedEvent do
  include_context "when it is a comment event"

  let(:organization) { create(:organization) }

  let(:event_name) { "decidim.events.comments.user_mentioned" }
  let(:ca_comment_content) { "<div><p>Un commentaire pour #{author_link}</p></div>" }
  let(:en_comment_content) { "<div><p>Comment mentioning some user, #{author_link}</p></div>" }
  let(:author_link) { "<a href=\"http://#{organization.host}:#{Capybara.server_port}/profiles/#{author.nickname}\" data-external-link=\"false\" target=\"_blank\" rel=\"nofollow noopener noreferrer ugc\">@#{author.nickname}</a>" }
  let(:parsed_body) { Decidim::ContentProcessor.parse("Comment mentioning some user, @#{author.nickname}", current_organization: organization) }
  let(:parsed_ca_body) { Decidim::ContentProcessor.parse("Un commentaire pour @#{author.nickname}", current_organization: organization) }
  let(:body) { { en: parsed_body.rewrite, machine_translations: { ca: parsed_ca_body.rewrite } } }

  let(:participatory_process) { create(:participatory_process, organization:) }
  let(:component) { create(:component, participatory_space: participatory_process) }
  let(:commentable) { create(:dummy_resource, component:) }

  let(:author) { create(:user, organization:) }
  let!(:comment) { create(:comment, body:, author:, commentable:) }
  let(:user) { create(:user, organization:, locale: "ca") }
  let(:notification_title) { "You have been mentioned in <a href=\"#{resource_path}?commentId=#{comment.id}#comment_#{comment.id}\">#{resource_title}</a> by <a href=\"/profiles/#{author.nickname}\">#{author.name} @#{author.nickname}</a>" }
  let(:email_subject) { "You have been mentioned in #{resource_title}" }
  let(:email_intro) { "You have been mentioned" }
  let(:email_outro) { "You have received this notification because you have been mentioned in #{resource_title}." }

  it_behaves_like "a comment event"
  it_behaves_like "a simple event email"
  it_behaves_like "a simple event notification"

  describe "resource_text" do
    it "correctly renders comments with mentions" do
      expect(subject.resource_text).not_to include("gid://")
      expect(subject.resource_text).to include("@#{author.nickname}")
    end
  end

  describe "translated notifications" do
    let(:en_body) { parsed_body.rewrite }

    let(:body) { { en: en_body, machine_translations: { ca: parsed_ca_body.rewrite } } }

    let(:participatory_process) { create(:participatory_process, organization:) }
    let(:component) { create(:component, participatory_space: participatory_process) }
    let(:commentable) { create(:dummy_resource, component:) }
    let!(:comment) { create(:comment, body:, author:, commentable:) }
    let(:en_version) { en_comment_content }
    let(:machine_translated) { ca_comment_content }
    let(:translatable) { true }

    it_behaves_like "a translated event"
  end
end
