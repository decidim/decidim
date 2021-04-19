# frozen_string_literal: true

module Decidim
  class StaticPageTopic < ApplicationRecord
    validates :title, presence: true
    include Decidim::TranslatableResource

    translatable_fields :title, :description

    default_scope { order(arel_table[:weight].asc) }

    belongs_to :organization, class_name: "Decidim::Organization"
    has_many :pages, class_name: "Decidim::StaticPage", foreign_key: "topic_id", dependent: :nullify

    def accessible_pages_for(user)
      pages.accessible_for(organization, user)
    end
  end
end
