# frozen_string_literal: true

require "spec_helper"

describe Decidim::ResourceEndorsedEvent do
  include_context "when a simple event"

  let(:event_name) { "decidim.events.resource_endorsed" }
  let(:author) { create :user, organization: resource.organization }

  let(:extra) { { endorser_id: author.id } }
  let(:resource) { create :dummy_resource, title: { en: "My super dummy resource" } }
  let(:resource_type) { "Dummy resource" }
  let(:endorsement) { create :endorsement, resource: resource, author: author }
  let(:resource_path) { resource_locator(resource).path }
  let(:follower) { create(:user, organization: resource.organization) }
  let(:follow) { create(:follow, followable: author, user: follower) }

  it_behaves_like "a simple event"

  describe "types" do
    subject { described_class }

    it "supports notifications" do
      expect(subject.types).to include :notification
    end

    it "supports emails" do
      expect(subject.types).to include :email
    end
  end

  describe "email_subject" do
    it "is generated correctly" do
      expect(subject.email_subject).to eq("#{author_presenter.nickname} has performed a new endorsement")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro)
        .to eq("#{author.name} #{author_presenter.nickname}, who you are following," \
               " has just endorsed \"#{translated resource.title}\" and we think it may be interesting to you. Check it out and contribute:")
    end
  end

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title)
        .to include("The <a href=\"#{resource_path}\">#{translated resource.title}</a> #{resource_type} has been endorsed by ")

      expect(subject.notification_title)
        .to include("<a href=\"/profiles/#{author.nickname}\">#{author.name} #{author_presenter.nickname}</a>.")
    end
  end

  describe "resource_text" do
    it "shows the resource body" do
      expect(subject.resource_text).to eq resource.body
    end
  end
end
