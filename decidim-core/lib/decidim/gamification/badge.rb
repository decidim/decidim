# frozen_string_literal: true

module Decidim
  module Gamification
    # This class represents an abstract badge. Instances of this class can define
    # different badge types with different rules such as gaining new levels, etc.
    class Badge
      include Decidim::AttributeObject::Model
      include ActiveModel::Validations

      # The name of the badge.
      attribute :name, String

      # An array of scores needed to reach a new level. For example, the array
      # [1, 5, 10] represents 1 point to get to Level 1, 5 points to get to level 2,
      # 10 points to get to level 3.
      attribute :levels, Array[Integer], default: []

      # An array of types for which this badge is valid for.
      attribute :valid_for, Array[Symbol], default: [:user]

      # (Optional) you can set a lambda in order to be able to reset the score of a
      # badge if the progress gets lost somehow. The lambda receives a user as an
      # argument.
      #
      # It might not be possible sometimes, so it's fine to leave it empty.
      attribute :reset, Proc

      validates :name, :levels, presence: true

      validate do
        errors.add(:levels, "level thresholds should be ordered") if levels.sort != levels
        errors.add(:levels, "level thresholds should be positive") unless levels.all?(&:positive?)
        errors.add(:levels, "level thresholds should be unique") unless levels.uniq == levels
      end

      # Public: Returns the level for this badge given a score.
      #
      # Returns an Integer with the level.
      def level_of(score)
        levels.each_with_index do |threshold, index|
          return index if threshold > score
        end

        levels.length
      end

      def translated_name
        I18n.t "name", scope: translation_scope
      end

      def description(organization_name = nil)
        I18n.t("description", organization_name:, scope: translation_scope)
      end

      def conditions
        I18n.t("conditions", scope: translation_scope)
      end

      def score_descriptions(score)
        {
          unearned_own: I18n.t("unearned_own", scope: translation_scope),
          description_own: I18n.t("description_own", score:, scope: translation_scope),
          unearned_another: I18n.t("unearned_another", scope: translation_scope),
          description_another: I18n.t("description_another", score:, scope: translation_scope)
        }
      end

      # Public: Returns an image for this badge.
      #
      # Returns a String with the image.
      def image
        ActionController::Base.helpers.asset_pack_path("media/images/decidim_gamification_badges_#{name}.svg")
      end

      def valid_for?(model)
        valid_for.include?(model.class.name.demodulize.underscore.to_sym)
      end

      private

      def translation_scope
        "decidim.gamification.badges.#{name}"
      end
    end
  end
end
