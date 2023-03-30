# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::RejectedProposalEvent do
  let(:resource) { create :proposal, :with_answer, title: "It is my super proposal" }
  let(:resource_title) { translated(resource.title) }
  let(:event_name) { "decidim.events.proposals.proposal_rejected" }

  include_context "when a simple event"
  it_behaves_like "a simple event"

  describe "email_subject" do
    it "is generated correctly" do
      expect(subject.email_subject).to eq("A proposal you are following has been rejected")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro)
        .to eq("The proposal \"#{decidim_html_escape(resource_title)}\" has been rejected. You can read the answer in this page:")
    end
  end

  describe "email_outro" do
    it "is generated correctly" do
      expect(subject.email_outro)
        .to eq("You have received this notification because you are following \"#{decidim_html_escape(resource_title)}\". You can unfollow it from the previous link.")
    end
  end

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title)
        .to include("The <a href=\"#{resource_path}\">#{decidim_html_escape(resource_title)}</a> proposal has been rejected")
    end
  end

  describe "resource_text" do
    it "shows the proposal answer" do
      expect(subject.resource_text).to eq translated(resource.answer)
    end
  end

  describe "proposal event rejected" do
    let!(:component_name) { :proposal_component }
    let!(:resource) { :proposal }

    let!(:form) do
      Decidim::Proposals::Admin::ProposalAnswerForm.from_params(form_params).with_context(
        current_user: user,
        current_component: record.component,
        current_organization: organization
      )
    end

    let(:form_params) do
      {
        internal_state: "rejected",
        answer: { en: "Foo" },
        cost: 2000,
        cost_report: { en: "Cost report" },
        execution_period: { en: "Execution period" }
      }
    end

    let!(:command) { Decidim::Proposals::Admin::AnswerProposal.new(form, record) }

    it_behaves_like "event notification"
  end
end
