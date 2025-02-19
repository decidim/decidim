# frozen_string_literal: true

module Decidim
  # This concern contains the logic associated with verifications and
  # rejections of groups
  #
  module ActsAsVerifiable
    extend ActiveSupport::Concern

    included do
      scope :verified, -> { where.not("extended_data->>'verified_at' IS ?", nil) }
      scope :not_verified, -> { where("extended_data->>'verified_at' IS ?", nil) }
      scope :rejected, -> { where.not("extended_data->>'rejected_at' IS ?", nil) }
      scope :pending, -> { where("extended_data->>'rejected_at' IS ? AND extended_data->>'verified_at' IS ?", nil, nil) }

      # Public: Checks if the user group is verified.
      def verified?
        verified_at.present?
      end

      # Public: Checks if the user group is rejected.
      def rejected?
        rejected_at.present?
      end

      # Public: Checks if the user group is pending.
      def pending?
        verified_at.blank? && rejected_at.blank?
      end

      def rejected_at
        extended_data["rejected_at"]
      end

      def verified_at
        extended_data["verified_at"]
      end

      def reject!
        extended_data["verified_at"] = nil
        extended_data["rejected_at"] = Time.current
        save!
      end

      def verify!
        extended_data["verified_at"] = Time.current
        extended_data["rejected_at"] = nil
        save!
      end
    end
  end
end
