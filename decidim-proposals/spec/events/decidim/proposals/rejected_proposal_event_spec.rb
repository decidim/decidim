# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::RejectedProposalEvent do
  let(:resource) { create(:proposal, :with_answer, title: "It is my super proposal") }
  let(:resource_title) { translated(resource.title) }
  let(:event_name) { "decidim.events.proposals.proposal_rejected" }
  let(:email_subject) { "A proposal you are following has been rejected" }
  let(:email_intro) { "The proposal \"#{decidim_html_escape(resource_title)}\" has been rejected. You can read the answer in this page:" }
  let(:email_outro) { "You have received this notification because you are following \"#{decidim_html_escape(resource_title)}\". You can unfollow it from the previous link." }
  let(:notification_title) { "The <a href=\"#{resource_path}\">#{decidim_html_escape(resource_title)}</a> proposal has been rejected." }
  let(:resource_text) { translated(resource.answer) }

  include_context "when a simple event"
  it_behaves_like "a simple event"
  it_behaves_like "a simple event email"
  it_behaves_like "a simple event notification"
end
