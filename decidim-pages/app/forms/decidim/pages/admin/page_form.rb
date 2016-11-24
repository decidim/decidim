# frozen_string_literal: true
module Decidim
  module Pages
    module Admin
      # This class holds a Form to update pages from Decidim's admin panel.
      class PageForm < Rectify::Form
        include TranslatableAttributes

        translatable_attribute :title, String
        translatable_attribute :body, String

        validates :title, translatable_presence: true
      end
    end
  end
end
