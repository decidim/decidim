# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe CreationEnabledEvent do
      include Decidim::ComponentPathHelper

      include_context "when a simple event"

      let(:event_name) { "decidim.events.proposals.creation_enabled" }
      let(:resource) { create(:proposal_component) }
      let(:resource_path) { main_component_path(resource) }
      let(:email_subject) { "Proposals now available in #{participatory_space_title}" }
      let(:email_intro) { "You can now create new proposals in #{participatory_space_title}! Start participating in this page:" }
      let(:email_outro) { "You have received this notification because you are following #{participatory_space_title}. You can stop receiving notifications following the previous link." }
      let(:notification_title) { "You can now put forward <a href=\"#{resource_path}\">new proposals</a> in <a href=\"#{participatory_space_url}\">#{participatory_space_title}</a>." }

      it_behaves_like "a simple event"
      it_behaves_like "a simple event email"
      it_behaves_like "a simple event notification"
    end
  end
end
