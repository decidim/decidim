# frozen_string_literal: true

module Decidim
  module Debates
    module Admin
      # This controller is the abstract class from which all other controllers of
      # this engine inherit.
      #
      # Note that it inherits from `Decidim::Components::BaseController`, which
      # override its layout and provide all kinds of useful methods.
      class ApplicationController < Decidim::Admin::Components::BaseController
        include NeedsPermission

        private

        def permission_class
          Decidim::Debates::Permissions
        end

        def permission_scope
          :admin
        end
      end
    end
  end
end
