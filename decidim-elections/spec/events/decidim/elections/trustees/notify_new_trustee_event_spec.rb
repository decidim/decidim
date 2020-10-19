# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Trustees::NotifyNewTrusteeEvent do
  include_context "when a simple event"

  let(:event_name) { "decidim.events.elections.trustees.new_trustee" }
  let(:resource) { create(:participatory_process) }
  let(:participatory_space_title) { resource.title["en"] }
  let(:resource_title) { resource.title["en"] }
  let(:create_public_key_path) { "{create_public_key_path}" }

  it_behaves_like "a simple event"

  describe "email_subject" do
    it "is generated correctly" do
      expect(subject.email_subject).to eq("You are a trustee for #{participatory_space_title}.")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro)
        .to eq("An admin has added you as trustee for #{participatory_space_title}. You should create your public key here: LINK")
    end
  end

  # describe "email_outro" do
  #   it "is generated correctly" do
  #     expect(subject.email_outro)
  #       .to eq("You have received this notification because you are following #{participatory_space_title}. You can stop receiving notifications following the previous link.")
  #   end
  # end

  # describe "notification_title" do
  #   it "is generated correctly" do
  #     expect(subject.notification_title)
  #       .to eq("The <a href=\"#{resource_path}\">#{resource_title}</a> election is now active for #{participatory_space_title}.")
  #   end
  # end
end
