# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::EvaluatingProposalEvent do
  let(:resource) { create(:proposal, title: "My super proposal") }
  let(:event_name) { "decidim.events.proposals.proposal_evaluating" }
  let(:email_subject) { "A proposal you are following is being evaluated" }
  let(:email_intro) { "The proposal \"#{translated(resource.title)}\" is currently being evaluated. You can check for an answer in this page:" }
  let(:email_outro) { "You have received this notification because you are following \"#{translated(resource.title)}\". You can unfollow it from the previous link." }
  let(:notification_title) { "The <a href=\"#{resource_path}\">#{translated(resource.title)}</a> proposal is being evaluated." }

  include_context "when a simple event"
  it_behaves_like "a simple event"
  it_behaves_like "a simple event email"
  it_behaves_like "a simple event notification"
end
