# frozen_string_literal: true

module Decidim
  # A hasthag is used to categorize components
  class Hashtag < ApplicationRecord
    self.table_name = "decidim_hashtags"

    belongs_to :organization, foreign_key: "decidim_organization_id", class_name: "Decidim::Organization"

    validates :name, presence: true
    validates :name, uniqueness: { scope: [:decidim_organization_id] }
  end
end
