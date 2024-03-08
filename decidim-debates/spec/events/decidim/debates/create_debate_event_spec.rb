# frozen_string_literal: true

require "spec_helper"

describe Decidim::Debates::CreateDebateEvent do
  include_context "when a simple event"

  let(:resource) { create(:debate, :participant_author, title: generate_localized_title(:debate_title)) }
  let(:space) { resource.participatory_space }
  let(:event_name) { "decidim.events.debates.debate_created" }
  let(:extra) { { type: type.to_s } }

  describe "resource_text" do
    let(:type) { "" }

    it "returns the debate description" do
      expect(subject.resource_text).to eq translated(resource.description)
    end
  end

  context "when the notification is for user followers" do
    let(:type) { :user }
    let(:i18n_scope) { "decidim.events.debates.create_debate_event.user_followers" }
    let(:email_subject) { "New debate \"#{resource_title}\" by @#{author.nickname}" }
    let(:email_intro) { "Hi,\n#{author.name} @#{author.nickname}, who you are following, has created a new debate \"#{resource_title}\". Check it out and contribute:" }
    let(:email_outro) { "You have received this notification because you are following @#{author.nickname}. You can stop receiving notifications following the previous link." }
    let(:notification_title) { "<a href=\"/profiles/#{author.nickname}\">#{author.name} @#{author.nickname}</a> created the <a href=\"#{resource_path}\">#{resource_title}</a> debate." }

    it_behaves_like "a simple event"
    it_behaves_like "a simple event email"
    it_behaves_like "a simple event notification"
  end

  context "when the notification is for space followers" do
    let(:type) { :space }
    let(:i18n_scope) { "decidim.events.debates.create_debate_event.space_followers" }
    let(:email_subject) { "New debate \"#{resource_title}\" on #{participatory_space_title}" }
    let(:email_intro) { "Hi,\nA new debate \"#{resource_title}\" has been created on the #{participatory_space_title} participatory space, check it out and contribute:" }
    let(:email_outro) { "You have received this notification because you are following the #{participatory_space_title} participatory space. You can stop receiving notifications following the previous link." }
    let(:notification_title) { "The <a href=\"#{resource_path}\">#{resource_title}</a> debate was created on <a href=\"#{participatory_space_url}\">#{participatory_space_title}</a>." }

    it_behaves_like "a simple event"
    it_behaves_like "a simple event email"
    it_behaves_like "a simple event notification"
  end
end
