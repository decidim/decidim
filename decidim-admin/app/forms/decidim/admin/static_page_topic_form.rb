# frozen_string_literal: true

module Decidim
  module Admin
    # A form object to create or update pages.
    class StaticPageTopicForm < Form
      include TranslatableAttributes

      translatable_attribute :title, String
      translatable_attribute :description, String

      mimic :static_page_topic

      validates :title, translatable_presence: true
    end
  end
end
