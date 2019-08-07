# frozen_string_literal: true

module Decidim
  module Sortitions
    module Admin
      class DestroySortitionForm < Form
        include TranslatableAttributes

        mimic :sortition

        translatable_attribute :cancel_reason, String

        validates :cancel_reason, translatable_presence: true

        delegate :current_participatory_space, to: :context
        delegate :current_component, to: :context
      end
    end
  end
end
