# frozen_string_literal: true

module Decidim
  module Admin
    # A form object used to configure a content block from the admin panel.
    #
    class HelpSectionsForm < Decidim::Form
      attribute :sections, Array[HelpSectionForm]
    end
  end
end
