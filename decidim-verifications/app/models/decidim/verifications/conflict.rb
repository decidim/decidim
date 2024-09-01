# frozen_string_literal: true

module Decidim::Verifications
  class Conflict < ApplicationRecord
    belongs_to :current_user, class_name: "User"
    belongs_to :managed_user, class_name: "User"

    def self.ransackable_attributes(_auth_object = nil)
      []
    end

    def self.ransackable_associations(_auth_object = nil)
      %w(current_user)
    end
  end
end
