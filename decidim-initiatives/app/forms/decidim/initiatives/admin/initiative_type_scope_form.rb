# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      # A form object used to collect the all the scopes related to an
      # initiative type
      class InitiativeTypeScopeForm < Form
        mimic :initiatives_type_scope

        attribute :supports_required, Integer
        attribute :decidim_scopes_id, Integer

        validates :supports_required,
                  presence: true,
                  numericality: {
                    only_integer: true,
                    greater_than: 0
                  }
      end
    end
  end
end
