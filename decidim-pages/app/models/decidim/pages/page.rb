# frozen_string_literal: true
module Decidim
  module Pages
    # The data store for a Page in the Decidim::Pages component. It stores a
    # title, description and any other useful information to render a custom page.
    class Page < Pages::ApplicationRecord
      validates :title, presence: true
      belongs_to :component, foreign_key: "decidim_component_id", class_name: Decidim::Component
    end
  end
end
