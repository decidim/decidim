# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # The main admin application controller for conferences
      class ApplicationController < Decidim::Admin::ApplicationController
        private

        def permissions_context
          super.merge(
            current_participatory_space: try(:current_participatory_space)
          )
        end

        def permission_class_chain
          [
            Decidim::Conferences::Permissions,
            Decidim::Admin::Permissions
          ]
        end
      end
    end
  end
end
