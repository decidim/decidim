# frozen_string_literal: true

module Decidim
  module Initiatives
    # A form object used to collect the initiative type for an initiative.
    class SelectInitiativeTypeForm < Form
      mimic :initiative

      attribute :type_id, Integer

      validates :type_id, presence: true
    end
  end
end
