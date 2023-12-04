# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::Admin::UpdateProposalCategoryEvent do
  let(:resource) { create(:proposal, title: "It is my super proposal") }
  let(:event_name) { "decidim.events.proposals.proposal_update_category" }
  let(:email_subject) { "The #{translated(resource.title)} proposal category has been updated" }
  let(:email_intro) { "An admin has updated the category of your proposal \"#{decidim_html_escape(translated(resource.title))}\", check it out in this page:" }
  let(:email_outro) { "You have received this notification because you are the author of the proposal." }
  let(:notification_title) { "The <a href=\"#{resource_path}\">#{decidim_html_escape(translated(resource.title))}</a> proposal category has been updated by an admin." }

  include_context "when a simple event"
  it_behaves_like "a simple event"
  it_behaves_like "a simple event email"
  it_behaves_like "a simple event notification"
end
