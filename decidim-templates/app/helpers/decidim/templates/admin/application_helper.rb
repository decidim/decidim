# frozen_string_literal: true

module Decidim
  module Templates
    # Custom helpers, scoped to the templates engine.
    #
    module Admin
      module ApplicationHelper
        def block_user_templates
          Decidim::Templates::Template.where(
            target: :user_block,
            templatable: [current_organization]
          ).order(:templatable_id)
        end
      end
    end
  end
end
