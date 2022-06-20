# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::Admin::UpdateProposalCategoryEvent do
  let(:resource) { create :proposal, title: "It's my super proposal" }
  let(:event_name) { "decidim.events.proposals.proposal_update_category" }

  include_context "when a simple event"
  it_behaves_like "a simple event"

  describe "email_subject" do
    it "is generated correctly" do
      expect(subject.email_subject).to eq("The #{translated(resource.title)} proposal category has been updated")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro)
        .to eq("An admin has updated the category of your proposal \"#{decidim_html_escape(translated(resource.title))}\", check it out in this page:")
    end
  end

  describe "email_outro" do
    it "is generated correctly" do
      expect(subject.email_outro)
        .to eq("You have received this notification because you are the author of the proposal.")
    end
  end

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title)
        .to include("The <a href=\"#{resource_path}\">#{decidim_html_escape(translated(resource.title))}</a> proposal category has been updated by an admin.")
    end
  end
end
