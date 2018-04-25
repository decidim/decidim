# frozen_string_literal: true

module Decidim
  module Initiatives
    # A form object used to collect the title and description for an initiative.
    class PreviousForm < Form
      include TranslatableAttributes

      mimic :initiative

      attribute :title, String
      attribute :description, String
      attribute :type_id, Integer

      validates :title, :description, presence: true
      validates :title, length: { maximum: 150 }
      validates :type_id, presence: true
    end
  end
end
