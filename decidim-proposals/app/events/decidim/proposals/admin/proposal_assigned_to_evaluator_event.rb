# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      class ProposalAssignedToEvaluatorEvent < Decidim::Events::SimpleEvent
        include Rails.application.routes.mounted_helpers

        i18n_attributes :admin_proposal_info_url, :admin_proposal_info_path

        def admin_proposal_info_path
          ResourceLocatorPresenter.new(resource).show
        end

        def admin_proposal_info_url
          EngineRouter.admin_proxy(resource.component).proposal_url(resource)
        end

        private

        def organization
          @organization ||= component.participatory_space.organization
        end
      end
    end
  end
end
