# frozen_string_literal: true

module Decidim
  module Pages
    module Admin
      # This class holds a Form to update pages from Decidim's admin panel.
      class PageForm < Decidim::Form
        include TranslatableAttributes

        translatable_attribute :body, String
      end
    end
  end
end
