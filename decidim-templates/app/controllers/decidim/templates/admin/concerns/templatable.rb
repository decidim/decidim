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
              @templates = current_organization.templates.where(templatable_type:)
              @templates = @templates.where.not(id: params[:id]) if templates_path?
              @templates
            end

            def templates_path?
              controller_path.match?("^decidim/templates/.*")
            end

            def choose_template?
              return false if templatable.is_a? Decidim::Templates::Template

              templates.any? && templatable.pristine?
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
