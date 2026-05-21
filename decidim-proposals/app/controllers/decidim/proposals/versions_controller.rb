# frozen_string_literal: true

module Decidim
  module Proposals
    # Exposes Proposals versions so users can see how a Proposal has been updated through time.
    class VersionsController < Decidim::Proposals::ApplicationController
      include Decidim::ApplicationHelper
      include Decidim::ResourceVersionsConcern

      def versioned_resource
        @versioned_resource ||= Proposal.not_hidden.published.where(component: current_component).find(params.expect(:proposal_id))
      end

      def add_breadcrumb_item
        return {} if versioned_resource.blank?

        {
          label: translated_attribute(versioned_resource.title),
          url: Decidim::EngineRouter.main_proxy(current_component).proposal_path(versioned_resource),
          active: false
        }
      end
    end
  end
end
