# frozen_string_literal: true

require "spec_helper"

describe Decidim::AttachmentCreatedEvent do
  include_context "when a simple event"

  let(:event_name) { "decidim.events.attachments.attachment_created" }
  let(:resource) { create(:attachment) }
  let(:attached_to_url) { resource_locator(attached_to).url }
  let(:resource_title) { attached_to.title["en"] }
  let(:resource_path) { resource.url }
  let(:attached_to) { resource.attached_to }

  before do
    resource.file.class.configure { |config| config.asset_host = "http://example.org" }
  end

  it_behaves_like "a simple event", true

  describe "email_subject" do
    it "is generated correctly" do
      expect(subject.email_subject).to eq("An update to #{resource_title}")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro).to eq("A new document has been added to #{resource_title}. You can see it from this page:")
    end
  end

  describe "resource_url" do
    it "is generated correctly" do
      expect(subject.resource_url).to eq(attached_to_url)
    end
  end

  describe "email_outro" do
    it "is generated correctly" do
      expect(subject.email_outro)
        .to include("You have received this notification because you are following #{resource_title}")
    end
  end

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title)
        .to eq("A <a href=\"#{resource_path}\">new document</a> has been added to <a href=\"#{attached_to_url}\">#{resource_title}</a>")
    end
  end

  describe "resource_text" do
    let(:text) { "This is my text!" }

    context "when attached_to has a description" do
      it "resturns the description" do
        expect(subject.resource_text).to eq translated(attached_to.description)
      end
    end

    context "when attached_to has a body" do
      it "resturns the description" do
        allow(attached_to).to receive(:description).and_return(nil)
        allow(attached_to).to receive(:body).and_return(text)
        expect(subject.resource_text).to eq attached_to.body
      end
    end
  end
end
