# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::ProposalStatusChangedEvent do
  context "when recipient is author" do
    shared_context "when author proposal changed the status" do |status|
      let(:event_name) { "decidim.events.proposals.proposal_status_changed" }
      let(:resource_title) { translated(resource.title) }

      let(:notification_title) { "Your proposal <a href=\"#{resource_path}\">#{resource_title}</a> has changed its status to \"#{status}\"." }
      let(:email_outro) { "You have received this notification because you are an author of \"#{resource_title}\"." }
      let(:email_intro) { "The proposal \"#{resource_title}\" has changed its status to \"#{status}\". You can read the answer in this page:" }
      let(:email_subject) { "Your proposal has changed its status (#{status})" }

      include_context "when a simple event" do
        let(:user_role) { :affected_user }
      end
      it_behaves_like "a simple event"
      it_behaves_like "a simple event email"
      it_behaves_like "a simple event notification"
    end

    context "when the proposal is evaluated" do
      let(:resource) { create(:proposal, :with_answer, :evaluating, title: "My super proposal") }

      include_context "when author proposal changed the status", "Evaluating"
    end

    context "when the proposal is rejected" do
      let(:resource) { create(:proposal, :with_answer, :rejected, title: "It is my super proposal") }

      include_context "when author proposal changed the status", "Rejected"

      describe "resource_text" do
        it "shows the proposal answer" do
          expect(subject.resource_text).to eq translated(resource.answer)
        end
      end
    end

    context "when the proposal is accepted" do
      let(:resource) { create(:proposal, :with_answer, :accepted, title: "My super proposal") }

      include_context "when author proposal changed the status", "Accepted"

      describe "resource_text" do
        it "shows the proposal answer" do
          expect(subject.resource_text).to eq translated(resource.answer)
        end
      end
    end
  end

  context "when recipient is follower" do
    let(:user_role) { :follower }

    shared_context "when followed proposal changed the status" do |status|
      let(:resource_title) { translated(resource.title) }
      let(:event_name) { "decidim.events.proposals.proposal_status_changed" }

      let(:email_intro) { "The proposal \"#{resource_title}\" has changed its status to \"#{status}\". You can read the answer in this page:" }
      let(:email_outro) { "You have received this notification because you are following \"#{resource_title}\". You can unfollow it from the previous link." }
      let(:email_subject) { "A proposal you are following has changed its status (#{status})" }

      let(:notification_title) { "The <a href=\"#{resource_path}\">#{resource_title}</a> proposal has changed its status to \"#{status}\"." }

      include_context "when a simple event"
      it_behaves_like "a simple event"
      it_behaves_like "a simple event email"
      it_behaves_like "a simple event notification"
    end

    context "when the proposal is evaluated" do
      let(:resource) { create(:proposal, :with_answer, :evaluating, title: "My super proposal") }

      include_context "when followed proposal changed the status", "Evaluating"
    end

    context "when the proposal is rejected" do
      let(:resource) { create(:proposal, :with_answer, :rejected, title: "It is my super proposal") }

      include_context "when followed proposal changed the status", "Rejected"

      describe "resource_text" do
        it "shows the proposal answer" do
          expect(subject.resource_text).to eq translated(resource.answer)
        end
      end
    end

    context "when the proposal is accepted" do
      let(:resource) { create(:proposal, :with_answer, :accepted, title: "My super proposal") }

      include_context "when followed proposal changed the status", "Accepted"

      describe "resource_text" do
        it "shows the proposal answer" do
          expect(subject.resource_text).to eq translated(resource.answer)
        end
      end
    end
  end
end
