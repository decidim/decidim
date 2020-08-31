# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Initiatives
    # Common methods for elements that need specific behaviour when there is only one initiative type.
    module SingleInitiativeType
      extend ActiveSupport::Concern

      included do
        helper_method :single_initiative_type?

        private

        def current_organization_initiatives_type
          Decidim::InitiativesType.where(organization: current_organization)
        end

        def single_initiative_type?
          current_organization_initiatives_type.count == 1
        end
      end
    end
  end
end
