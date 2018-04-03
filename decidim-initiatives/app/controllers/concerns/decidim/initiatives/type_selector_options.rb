# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Initiatives
    # Common logic for elements that need to be able to select initiative types.
    module TypeSelectorOptions
      extend ActiveSupport::Concern

      include Decidim::TranslationsHelper

      included do
        helper_method :available_initiative_types, :initiative_type_options,
                      :initiative_types_each

        private

        # Return all initiative types with scopes defined.
        def available_initiative_types
          Decidim::Initiatives::InitiativeTypes
            .for(current_organization)
            .joins(:scopes)
            .distinct
        end

        def initiative_type_options
          available_initiative_types.map do |type|
            [type.title[I18n.locale.to_s], type.id]
          end
        end

        def initiative_types_each
          available_initiative_types.each do |type|
            yield(type)
          end
        end
      end
    end
  end
end
