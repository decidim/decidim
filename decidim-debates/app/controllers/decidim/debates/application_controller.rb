# frozen_string_literal: true

module Decidim
  module Debates
    # This controller is the abstract class from which all other controllers of
    # this engine inherit.
    #
    # Note that it inherits from `Decidim::Components::BaseController`, which
    # override its layout and provide all kinds of useful methods.
    class ApplicationController < Decidim::Components::BaseController
      include NeedsPermission

      private

      def permission_class
        Decidim::Debates::Permissions
      end

      def permission_scope
        :public
      end
    end
  end
end
