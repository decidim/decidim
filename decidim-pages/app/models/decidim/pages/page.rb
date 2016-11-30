# frozen_string_literal: true
module Decidim
  module Pages
    # The data store for a Page in the Decidim::Pages component. It stores a
    # title, description and any other useful information to render a custom page.
    class Page < Pages::ApplicationRecord
      validates :title, :feature, presence: true
      belongs_to :feature, foreign_key: "decidim_feature_id", class_name: Decidim::Feature
    end
  end
end
