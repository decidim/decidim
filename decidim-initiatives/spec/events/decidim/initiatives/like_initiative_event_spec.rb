# frozen_string_literal: true

require "spec_helper"

describe Decidim::Initiatives::LikeInitiativeEvent do
  subject do
    described_class.new(resource:, event_name:, user:, extra: {})
  end

  include_context "when a simple event"

  include Decidim::TranslationsHelper

  let(:organization) { resource.organization }
  let(:resource) { create(:initiative) }
  let(:initiative_author) { resource.author }
  let(:event_name) { "decidim.events.initiatives.initiative_liked" }
  let(:user) { create(:user, organization:) }
  let(:resource_path) { resource_locator(resource).path }
  let(:email_subject) { "Initiative liked by @#{initiative_author.nickname}" }
  let(:email_intro) { "#{initiative_author.name} @#{initiative_author.nickname}, who you are following, has liked the following initiative, maybe you want to contribute to the conversation:" }
  let(:email_outro) { "You have received this notification because you are following @#{initiative_author.nickname}. You can stop receiving notifications following the previous link." }
  let(:notification_title) { <<-EOTITLE.squish }
    The <a href="#{resource_path}">#{resource_title}</a> initiative was liked by
    <a href="/profiles/#{initiative_author.nickname}">#{initiative_author.name} @#{initiative_author.nickname}</a>.
  EOTITLE

  describe "types" do
    subject { described_class }

    it "supports notifications" do
      expect(subject.types).to include :notification
    end

    it "supports emails" do
      expect(subject.types).to include :email
    end
  end

  it_behaves_like "a simple event email"
  it_behaves_like "a simple event notification"
end
