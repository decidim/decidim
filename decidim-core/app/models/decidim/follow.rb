# frozen_string_literal: true

module Decidim
  class Follow < ApplicationRecord
    include Decidim::DataPortability

    belongs_to :followable, foreign_key: "decidim_followable_id", foreign_type: "decidim_followable_type", polymorphic: true
    belongs_to :user, foreign_key: "decidim_user_id", class_name: "Decidim::User"

    validates :user, uniqueness: { scope: [:followable] }

    def self.user_collection(user)
      where(decidim_user_id: user.id)
    end

    def self.export_serializer
      Decidim::DataPortabilitySerializers::DataPortabilityFollowSerializer
    end
  end
end
