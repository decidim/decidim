# frozen_string_literal: true

module Decidim
  class Notification < ApplicationRecord
    belongs_to :followable, foreign_key: "decidim_followable_id", foreign_type: "decidim_followable_type", polymorphic: true
    belongs_to :user, foreign_key: "decidim_user_id", class_name: "Decidim::User"
  end
end
