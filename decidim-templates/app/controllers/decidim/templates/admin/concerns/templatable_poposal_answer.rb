# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Templates
    module Admin
      module Concerns
        module TemplatablePoposalAnswer
          # Common logic to load template-related resources in controller
          extend ActiveSupport::Concern

          included do
            helper_method :proposal_answers_template_options

            def proposal_answers_template_options; end
          end
        end
      end
    end
  end
end
