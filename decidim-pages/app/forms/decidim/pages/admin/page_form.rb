# frozen_string_literal: true
module Decidim
  module Pages
    module Admin
      class PageForm < Rectify::Form
        include TranslatableAttributes
        translatable_attribute :title, String
        translatable_attribute :body, String

        translatable_validates :title, :body, presence: true
      end
    end
  end
end
