# frozen_string_literal: true

module Decidim
  module Comments
    # This controller is the abstract class from which all other controllers of
    # this engine inherit.
    class ApplicationController < Decidim::ApplicationController
      def permission_class_chain
        [
          ::Decidim::Comments::Permissions,
          ::Decidim::Permissions
        ]
      end
    end
  end
end
