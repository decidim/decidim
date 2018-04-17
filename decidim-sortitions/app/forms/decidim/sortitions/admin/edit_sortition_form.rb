# frozen_string_literal: true

module Decidim
  module Sortitions
    module Admin
      class EditSortitionForm < Form
        include TranslatableAttributes

        mimic :sortition

        translatable_attribute :title, String
        translatable_attribute :additional_info, String

        validates :title, translatable_presence: true
        validates :additional_info, translatable_presence: true

        delegate :current_participatory_space, to: :context
        delegate :current_component, to: :context
      end
    end
  end
end
