# frozen_string_literal: true

module Decidim
  class Hashtagging < ApplicationRecord
    self.table_name = "decidim_hashtaggings"

    belongs_to :decidim_hashtag, class_name: "Decidim::Hashtag"
    belongs_to :decidim_hashtaggable, class_name: "Decidim::Hashtaggable", polymorphic: true
  end
end
