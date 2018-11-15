# frozen_string_literal: true

module Decidim
  module Admin
    # This form contains the presentational and validation logic to update
    # ContextualHelpSections in batch from the admin panel.
    class HelpSectionsForm < Decidim::Form
      attribute :sections, Array[HelpSectionForm]
    end
  end
end
