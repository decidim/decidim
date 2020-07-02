# frozen_string_literal: true

module Decidim
  module Debates
    # Exposes Debates versions so users can see how a Debate has been updated
    # through time.
    class VersionsController < Decidim::Proposals::ApplicationController
      include Decidim::ApplicationHelper
      include Decidim::ResourceVersionsConcern

      def versioned_resource
        @versioned_resource ||= present(Debate.where(component: current_component).find(params[:debate_id]))
      end
    end
  end
end
