# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe LikingEnabledEvent do
      include Decidim::ComponentPathHelper

      include_context "when a simple event"

      let(:event_name) { "decidim.events.proposals.liking_enabled" }
      let(:resource) { create(:proposal_component) }
      let(:participatory_space) { resource.participatory_space }
      let(:resource_path) { main_component_path(resource) }
      let(:email_subject) { "Proposals liking has started for #{participatory_space_title}" }
      let(:email_intro) { "You can like proposals in #{participatory_space_title}! Start participating in this page:" }
      let(:email_outro) { "You have received this notification because you are following #{participatory_space_title}. You can stop receiving notifications following the previous link." }
      let(:notification_title) { "You can now start <a href=\"#{resource_path}\">liking proposals</a> in <a href=\"#{participatory_space_url}\">#{participatory_space_title}</a>." }

      it_behaves_like "a simple event"
      it_behaves_like "a simple event email"
      it_behaves_like "a simple event notification"
    end
  end
end
