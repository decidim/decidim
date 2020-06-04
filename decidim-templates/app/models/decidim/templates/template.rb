# frozen_string_literal: true

module Decidim
  class Template < ApplicationRecord
    belongs_to :organization,
               foreign_key: "decidim_organization_id",
               class_name: "Decidim::Organization"

    belongs_to :author, class_name: "Decidim::User", foreign_key: "decidim_author_id"
    belongs_to :model, foreign_key: "decidim_model_id", foreign_type: "decidim_model_type", polymorphic: true
  end
end
