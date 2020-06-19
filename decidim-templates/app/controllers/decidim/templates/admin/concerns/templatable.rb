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
            helper_method :templates, :choose_template?

            def templates
              current_organization.templates.where(templatable_type: templatable_type)
            end
            
            def choose_template?
              !controller_path.match?("^decidim/templates/.*") && templates.any? && templatable.pristine?
            end

            protected

            def templatable
              raise NotImplementedError, "Please set the templatable resource in your controller"
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
