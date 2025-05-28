# frozen_string_literal: true

require "spec_helper"

shared_examples_for "resource liked event" do
  include_context "when a simple event"

  let(:event_name) { "decidim.events.resource_liked" }
  let(:author) { create(:user, organization: resource.organization) }

  let(:extra) { { liker_id: author.id } }
  let(:like) { create(:like, resource:, author:) }
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
      expect(subject.email_subject).to eq("#{author_presenter.nickname} has performed a new like")
    end
  end

  describe "email_intro" do
    let(:resource_title) { decidim_sanitize_translated(resource.title) }
    it "is generated correctly" do
      expect(subject.email_intro)
        .to eq("#{author.name} #{author_presenter.nickname}, who you are following, " \
               "has just liked \"#{resource_title}\" and we think it may be interesting to you. Check it out and contribute:")
    end
  end

  describe "notification_title" do
    let(:resource_title) { decidim_sanitize_translated(resource.title) }

    it "is generated correctly" do
      expect(subject.notification_title)
        .to include("The <a href=\"#{resource_path}\">#{resource_title}</a> #{resource_type} has been liked by ")

      expect(subject.notification_title)
        .to include("<a href=\"/profiles/#{author.nickname}\">#{author.name} #{author_presenter.nickname}</a>.")
    end
  end

  describe "resource_text" do
    it "shows the resource text" do
      expect(subject.resource_text).to eq resource_text
    end
  end
end
