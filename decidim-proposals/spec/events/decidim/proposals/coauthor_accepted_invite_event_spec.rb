# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe CoauthorAcceptedInviteEvent do
      include_context "when a simple event"

      let(:resource) { create(:proposal) }
      let(:extra) do
        {
          "coauthor_id" => coauthor.id
        }
      end
      let(:notification_title) do
        "<a href=\"/profiles/#{coauthor.nickname}\">#{coauthor.name}</a> has accepted your invitation to become a co-author of the proposal <a href=\"#{resource_path}\">#{resource_title}</a>."
      end
      let(:participatory_process) { create(:participatory_process, organization:) }
      let(:proposal_component) { create(:proposal_component, participatory_space: participatory_process) }
      let(:resource_title) { decidim_sanitize_translated(resource.title) }
      let(:event_name) { "decidim.events.proposals.coauthor_accepted_invite" }
      let(:coauthor) { create(:user, organization: resource.organization) }

      it_behaves_like "a simple event notification"
      it_behaves_like "a notification event only"
    end
  end
end
