# frozen_string_literal: true

module Decidim
  class StaticPageTopic < ApplicationRecord
    validates :presence, title: true

    belongs_to :organization, class_name: "Decidim::Organization"
  end
end
