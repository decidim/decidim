# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::ProposalStateChangedEvent do
  context "when the proposal is evaluated" do
    let(:resource) { create(:proposal, :with_answer, title: "My super proposal") }
    let(:notification_title) { "The <a href=\"#{resource_path}\">#{resource_title}</a> proposal is being evaluated." }

    let(:email_outro) { "You have received this notification because you are following \"#{resource_title}\". You can unfollow it from the previous link." }
    let(:email_intro) { "The proposal \"#{resource_title}\" is currently being evaluated. You can check for an answer in this page:" }
    let(:email_subject) { "A proposal you are following is being evaluated" }
    let(:resource_title) { translated(resource.title) }
    let(:event_name) { "decidim.events.proposals.proposal_evaluating" }

    include_context "when a simple event"
    it_behaves_like "a simple event"
    it_behaves_like "a simple event email"
    it_behaves_like "a simple event notification"
  end

  context "when the proposal is rejected" do
    let(:resource) { create(:proposal, :with_answer, title: "It is my super proposal") }
    let(:resource_title) { translated(resource.title) }
    let(:event_name) { "decidim.events.proposals.proposal_rejected" }
    let(:email_subject) { "A proposal you are following has been rejected" }
    let(:email_intro) { "The proposal \"#{decidim_html_escape(resource_title)}\" has been rejected. You can read the answer in this page:" }
    let(:email_outro) { "You have received this notification because you are following \"#{decidim_html_escape(resource_title)}\". You can unfollow it from the previous link." }

    let(:notification_title) { "The <a href=\"#{resource_path}\">#{decidim_html_escape(resource_title)}</a> proposal has been rejected." }

    include_context "when a simple event"
    it_behaves_like "a simple event"
    it_behaves_like "a simple event email"
    it_behaves_like "a simple event notification"

    describe "resource_text" do
      it "shows the proposal answer" do
        expect(subject.resource_text).to eq translated(resource.answer)
      end
    end
  end

  context "when the proposal is accepted" do
    let(:resource) { create(:proposal, :with_answer, title: "My super proposal") }
    let(:resource_title) { translated(resource.title) }
    let(:event_name) { "decidim.events.proposals.proposal_accepted" }
    let(:email_subject) { "A proposal you are following has been accepted" }
    let(:email_intro) { "The proposal \"#{resource_title}\" has been accepted. You can read the answer in this page:" }
    let(:email_outro) { "You have received this notification because you are following \"#{resource_title}\". You can unfollow it from the previous link." }
    let(:notification_title) { "The <a href=\"#{resource_path}\">#{resource_title}</a> proposal has been accepted." }

    include_context "when a simple event"
    it_behaves_like "a simple event"
    it_behaves_like "a simple event email"
    it_behaves_like "a simple event notification"

    describe "resource_text" do
      it "shows the proposal answer" do
        expect(subject.resource_text).to eq translated(resource.answer)
      end
    end
  end
end
