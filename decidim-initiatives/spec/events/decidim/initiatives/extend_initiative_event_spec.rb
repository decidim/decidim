# frozen_string_literal: true

require "spec_helper"

describe Decidim::Initiatives::ExtendInitiativeEvent do
  include_context "when a simple event"

  let(:event_name) { "decidim.events.initiatives.initiative_extended" }
  let(:resource) { initiative }

  let(:initiative) { create :initiative }
  let(:participatory_space) { initiative }

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
      expect(subject.email_subject).to eq("Initiative signatures end date extended!")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro)
        .to eq("The signatures end date for the initiative #{resource_title} have been extended!")
    end
  end

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title)
        .to include("The signatures end date for the <a href=\"#{resource_path}\">#{resource_title}</a> initiative have been extended")
    end
  end
end
