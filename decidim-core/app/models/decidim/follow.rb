# frozen_string_literal: true

module Decidim
  class Follow < ApplicationRecord
    belongs_to :followable, foreign_key: "decidim_followable_id", foreign_type: "decidim_followable_type", polymorphic: true
    belongs_to :user, foreign_key: "decidim_user_id", class_name: "Decidim::User"

    validates :user, uniqueness: { scope: [:followable] }
  end
end
