# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Debates
    describe CreationDisabledEvent do
      include Decidim::ComponentPathHelper

      include_context "when a simple event"

      let(:event_name) { "decidim.events.debates.creation_disabled" }
      let(:resource) { create(:debates_component) }
      let(:participatory_space) { resource.participatory_space }
      let(:resource_path) { main_component_path(resource) }
      let(:email_subject) { "Debate creation disabled in #{participatory_space_title}" }
      let(:email_intro) { "Debate creation is no longer active in #{participatory_space_title}. You can still participate in open debates from this page:" }
      let(:email_outro) { "You have received this notification because you are following #{participatory_space_title}. You can stop receiving notifications following the previous link." }
      let(:notification_title) { "Debate creation is now disabled in <a href=\"#{participatory_space_url}\">#{participatory_space_title}</a>" }

      it_behaves_like "a simple event"
      it_behaves_like "a simple event email"
      it_behaves_like "a simple event notification"
    end
  end
end
