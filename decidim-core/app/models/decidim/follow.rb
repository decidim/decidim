# frozen_string_literal: true

module Decidim
  class Follow < ApplicationRecord
    include Decidim::DataPortability

    belongs_to :followable, foreign_key: "decidim_followable_id", foreign_type: "decidim_followable_type", polymorphic: true
    belongs_to :user, foreign_key: "decidim_user_id", class_name: "Decidim::User"

    validates :user, uniqueness: { scope: [:followable] }

    after_create :increase_following_counters
    after_create :increase_followers_counter

    after_destroy :decrease_following_counters
    after_destroy :decrease_followers_counter

    def self.user_collection(user)
      where(decidim_user_id: user.id)
    end

    def self.export_serializer
      Decidim::DataPortabilitySerializers::DataPortabilityFollowSerializer
    end

    private

    # rubocop:disable Rails/SkipsModelValidations
    def increase_following_counters
      user.increment!(:following_users_count) if decidim_followable_type == "Decidim::UserBaseEntity"
      user.increment!(:following_count)
    end

    def increase_followers_counter
      return unless followable.is_a?(Decidim::UserBaseEntity)
      followable.increment!(:followers_count)
    end

    def decrease_following_counters
      return unless user
      user.decrement!(:following_users_count) if decidim_followable_type == "Decidim::UserBaseEntity"
      user.decrement!(:following_count)
    end

    def decrease_followers_counter
      return unless followable.is_a?(Decidim::UserBaseEntity)
      return unless user
      followable.decrement!(:followers_count)
    end
    # rubocop:enable Rails/SkipsModelValidations
  end
end
