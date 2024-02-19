# frozen_string_literal: true

require "spec_helper"

describe Decidim::Initiatives::CreateInitiativeEvent do
  subject do
    described_class.new(resource:, event_name:, user:, extra: {})
  end

  include_context "when a simple event"

  let(:organization) { resource.organization }
  let(:resource) { create(:initiative) }
  let(:initiative_author) { resource.author }
  let(:event_name) { "decidim.events.initiatives.initiative_created" }
  let(:user) { create(:user, organization:) }
  let(:resource_path) { resource_locator(resource).path }
  let(:email_subject) { "New initiative by @#{initiative_author.nickname}" }
  let(:email_intro) { "#{initiative_author.name} @#{initiative_author.nickname}, who you are following, has created a new initiative, check it out and contribute:" }
  let(:email_outro) { "You have received this notification because you are following @#{initiative_author.nickname}. You can stop receiving notifications following the previous link." }
  let(:notification_title) { "The <a href=\"#{resource_path}\">#{resource_title}</a> initiative was created by <a href=\"/profiles/#{initiative_author.nickname}\">#{initiative_author.name} @#{initiative_author.nickname}</a>." }

  it_behaves_like "a simple event email"
  it_behaves_like "a simple event notification"

  describe "types" do
    subject { described_class }

    it "supports notifications" do
      expect(subject.types).to include :notification
    end

    it "supports emails" do
      expect(subject.types).to include :email
    end
  end
end
