# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Templates
    module Admin
      module Concerns
        module Templatable
          # Common logic to load template-related resources in controller
          extend ActiveSupport::Concern

          included do
            helper_method :templates

            def templates
              current_organization.templates.where(templatable_type: templatable_type)
            end

            def templatable_type
              raise NotImplementedError, "The templatable type is needed to load resources"
            end
          end
        end
      end
    end
  end
end
