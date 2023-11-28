# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe EndorsingEnabledEvent do
      include Decidim::ComponentPathHelper

      include_context "when a simple event"

      let(:event_name) { "decidim.events.proposals.endorsing_enabled" }
      let(:email_subject) { "Proposals endorsing has started for #{participatory_space.title["en"]}" }
      let(:email_intro) { "You can endorse proposals in #{participatory_space_title}! Start participating in this page:" }
      let(:email_outro) { "You have received this notification because you are following #{participatory_space.title["en"]}" }
      let(:notification_title) { "You can now start <a href=\"#{resource_path}\">endorsing proposals</a> in <a href=\"#{participatory_space_url}\">#{participatory_space.title["en"]}</a>." }
      let(:resource) { create(:proposal_component) }
      let(:participatory_space) { resource.participatory_space }
      let(:resource_path) { main_component_path(resource) }

      let(:notification_title) { "You can now start <a href=\"#{resource_path}\">endorsing proposals</a> in <a href=\"#{participatory_space_url}\">#{participatory_space.title["en"]}</a>." }
      let(:email_outro) { "You have received this notification because you are following #{participatory_space.title["en"]}" }
      let(:email_intro) { "You can endorse proposals in #{participatory_space_title}! Start participating in this page:" }
      let(:email_subject) { "Proposals endorsing has started for #{participatory_space.title["en"]}" }

      it_behaves_like "a simple event"
    end
  end
end
