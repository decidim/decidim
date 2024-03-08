# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::RejectedProposalEvent do
  let(:resource) { create :proposal, :with_answer, title: "It's my super proposal" }
  let(:event_name) { "decidim.events.proposals.proposal_rejected" }
  let(:email_subject) { "A proposal you're following has been rejected" }
  let(:email_intro) { "The proposal \"#{resource_title}\" has been rejected. You can read the answer in this page:" }
  let(:email_outro) { "You have received this notification because you are following \"#{resource_title}\". You can unfollow it from the previous link." }
  let(:notification_title) { "The <a href=\"#{resource_path}\">#{resource_title}</a> proposal has been rejected." }
  let(:resource_text) { translated(resource.answer) }

  include_context "when a simple event"
  it_behaves_like "a simple event"
  it_behaves_like "a simple event email"
  it_behaves_like "a simple event notification"
end
