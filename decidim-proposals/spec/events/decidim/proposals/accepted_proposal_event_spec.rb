# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::AcceptedProposalEvent do
  let(:resource) { create :proposal, :with_answer, title: "My super proposal" }
  let(:resource_title) { translated(resource.title) }
  let(:event_name) { "decidim.events.proposals.proposal_accepted" }

  include_context "when a simple event"
  it_behaves_like "a simple event"

  describe "email_subject" do
    it "is generated correctly" do
      expect(subject.email_subject).to eq("A proposal you are following has been accepted")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro)
        .to eq("The proposal \"#{resource_title}\" has been accepted. You can read the answer in this page:")
    end
  end

  describe "email_outro" do
    it "is generated correctly" do
      expect(subject.email_outro)
        .to eq("You have received this notification because you are following \"#{resource_title}\". You can unfollow it from the previous link.")
    end
  end

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title)
        .to include("The <a href=\"#{resource_path}\">#{resource_title}</a> proposal has been accepted")
    end
  end

  describe "resource_text" do
    it "shows the proposal answer" do
      expect(subject.resource_text).to eq translated(resource.answer)
    end
  end

  describe "notification digest mail" do
    let!(:component) { create(:proposal_component, organization:) }
    let!(:record) { create(:proposal, component:, users: [user], title: { en: "Event notifier" }) }

    let!(:form) do
      Decidim::Proposals::Admin::ProposalAnswerForm.from_params(form_params).with_context(
        current_user: user,
        current_component: record.component,
        current_organization: organization
      )
    end

    let(:form_params) do
      {
        internal_state: "accepted",
        answer: { en: "Example answer" },
        cost: 2000,
        cost_report: { en: "Example report" },
        execution_period: { en: "Example execution period" }
      }
    end

    let!(:command) { Decidim::Proposals::Admin::AnswerProposal.new(form, record) }

    context "when daily notification mail" do
      let(:user) { create(:user, :admin, organization:, notifications_sending_frequency: "daily") }

      it_behaves_like "notification digest mail"
    end

    context "when weekly notification mail" do
      let(:user) { create(:user, :admin, organization:, notifications_sending_frequency: "weekly") }

      it_behaves_like "notification digest mail"
    end
  end
end
