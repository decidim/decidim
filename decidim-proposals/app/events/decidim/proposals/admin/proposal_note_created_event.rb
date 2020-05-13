# frozen-string_literal: true

module Decidim
  module Proposals
    module Admin
      class ProposalNoteCreatedEvent < Decidim::Events::SimpleEvent
        include Rails.application.routes.mounted_helpers

        i18n_attributes :admin_proposal_info_url, :admin_proposal_info_path

        def admin_proposal_info_path
          ResourceLocatorPresenter.new(resource).show
        end

        def admin_proposal_info_url
          decidim_admin_participatory_process_proposals.proposal_url(resource, resource.component.mounted_params)
        end

        private

        def organization
          @organization ||= component.participatory_space.organization
        end
      end
    end
  end
end
