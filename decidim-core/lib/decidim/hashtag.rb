# frozen_string_literal: true

module Decidim
  # A hasthag is used to categorize components
  class Hashtag < ApplicationRecord
    self.table_name = "decidim_hashtags"

    belongs_to :organization, foreign_key: "decidim_organization_id", class_name: "Decidim::Organization"
    has_many :decidim_hashtaggings, dependent: :destroy, foreign_key: "decidim_hashtag_id", class_name: "Decidim::Hashtagging"

    validates :name, presence: true
    validates :name, uniqueness: { scope: [:decidim_organization_id] }

    HASHTAG_REGEX = /(^|\s)#([a-zA-Z0-9]\w*)/i

    def hashtaggables
      decidim_hashtaggings.includes(:decidim_hashtaggable).collect(&:decidim_hashtaggable)
    end

    def hashtagged_types
      decidim_hashtaggings.pluck(:decidim_hashtaggable_type).uniq
    end

    def hashtagged_ids_by_types
      hashtagged_ids ||= {}
      hashtaggings.each do |h|
        hashtagged_ids[h.decidim_hashtaggable_type] ||= []
        hashtagged_ids[h.decidim_hashtaggable_type] << h.decidim_hashtaggable_id
      end
      hashtagged_ids
    end

    def hashtagged_ids_for_type(type)
      hashtagged_ids_by_types[type]
    end
  end
end
