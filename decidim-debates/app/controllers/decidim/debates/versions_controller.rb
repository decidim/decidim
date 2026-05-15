# frozen_string_literal: true

module Decidim
  module Debates
    # Exposes Debates versions so users can see how a Debate has been updated
    # through time.
    class VersionsController < Decidim::Debates::ApplicationController
      include Decidim::ApplicationHelper
      include Decidim::ResourceVersionsConcern

      def versioned_resource
        @versioned_resource ||= Debate.where(component: current_component).not_hidden.find(params[:debate_id])
      end

      def add_breadcrumb_item
        return {} if versioned_resource.blank?

        {
          label: translated_attribute(versioned_resource.title),
          url: Decidim::EngineRouter.main_proxy(current_component).debate_path(versioned_resource),
          active: false
        }
      end
    end
  end
end
