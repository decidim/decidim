# frozen_string_literal: true

require "spec_helper"

describe Decidim::FeaturePublishedEvent do
  include Decidim::FeaturePathHelper

  include_context "simple event"

  let(:event_name) { "decidim.events.feature_published_event" }
  let(:resource) { create(:feature) }
  let(:participatory_space) { resource.participatory_space }
  let(:resource_path) { main_feature_path(resource) }

  it_behaves_like "a simple event"

  describe "email_subject" do
    it "is generated correctly" do
      expect(subject.email_subject).to eq("An update to #{participatory_space.title["en"]}")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro)
        .to eq("The #{resource.name["en"]} component is now active for #{participatory_space.title["en"]}. You can see it from this page:")
    end
  end

  describe "email_outro" do
    it "is generated correctly" do
      expect(subject.email_outro)
        .to include("You have received this notification because you are following #{participatory_space.title["en"]}")
    end
  end

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title)
        .to eq("The #{resource.name["en"]} component is now active for <a href=\"#{resource_path}\">#{participatory_space.title["en"]}</a>")
    end
  end
end
