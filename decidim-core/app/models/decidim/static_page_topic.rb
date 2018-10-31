# frozen_string_literal: true

module Decidim
  class StaticPageTopic < ApplicationRecord
    validates :title, presence: true

    belongs_to :organization, class_name: "Decidim::Organization"
    has_many :pages, class_name: "Decidim::StaticPage", foreign_key: "topic_id", dependent: :nullify
  end
end
