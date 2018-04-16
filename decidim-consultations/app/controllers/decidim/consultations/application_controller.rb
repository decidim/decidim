# frozen_string_literal: true

module Decidim
  module Consultations
    # A controller that holds the logic to show consultations in a
    # public layout.
    class ApplicationController < Decidim::ApplicationController
      include NeedsPermission

      private

      def permission_class_chain
        [
          Decidim::Consultations::Permissions,
          Decidim::Admin::Permissions,
          Decidim::Permissions
        ]
      end

      def permission_scope
        :public
      end
    end
  end
end
