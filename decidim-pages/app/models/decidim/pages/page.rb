# frozen_string_literal: true
module Decidim
  module Pages
    class Page < Pages::ApplicationRecord
      validates :title, presence: true
      belongs_to :component, foreign_key: "decidim_component_id", class_name: Decidim::Component
    end
  end
end
