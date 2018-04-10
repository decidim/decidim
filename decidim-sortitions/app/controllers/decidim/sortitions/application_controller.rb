# frozen_string_literal: true

module Decidim
  module Sortitions
    # This controller is the abstract class from which all other controllers of
    # this engine inherit.
    #
    # Note that it inherits from `Decidim::Components::BaseController`, which
    # override its layout and provide all kinds of useful methods.
    class ApplicationController < Decidim::Components::BaseController
      include NeedsPermission

      private

      def permission_class_chain
        [
          Decidim::Sortitions::Permissions,
          current_participatory_space.manifest.permissions_class,
          Decidim::Permissions
        ]
      end

      def permission_scope
        :public
      end
    end
  end
end
