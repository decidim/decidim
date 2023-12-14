# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::Admin::UpdateProposalScopeEvent do
  let(:resource) { create(:proposal, title: "It is my super proposal") }
  let(:resource_title) { translated(resource.title) }
  let(:event_name) { "decidim.events.proposals.proposal_update_scope" }
  let(:email_subject) { "The #{decidim_sanitize(resource_title)} proposal scope has been updated" }
  let(:email_intro) { "An admin has updated the scope of your proposal \"#{decidim_html_escape(resource_title)}\", check it out in this page:" }
  let(:email_outro) { "You have received this notification because you are the author of the proposal." }
  let(:notification_title) { "The <a href=\"#{resource_path}\">#{decidim_html_escape(resource_title)}</a> proposal scope has been updated by an admin." }

  include_context "when a simple event"
  it_behaves_like "a simple event"
  it_behaves_like "a simple event email"
  it_behaves_like "a simple event notification"
end
