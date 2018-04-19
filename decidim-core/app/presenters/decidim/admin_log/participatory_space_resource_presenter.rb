# frozen_string_literal: true

module Decidim
  module AdminLog
    # This class extends the default resource presenter for logs, so that
    # it can properly link to the participatory space.
    class ParticipatorySpaceResourcePresenter < Decidim::Log::ResourcePresenter
      private

      # Private: Finds the public name for the given participatory space.
      #
      # Returns an HTML-safe String.
      def present_resource_name
        I18n.t(resource.manifest_name, scope: "decidim.admin.menu")
      end
    end
  end
end
