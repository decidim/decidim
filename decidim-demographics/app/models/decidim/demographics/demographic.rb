# frozen_string_literal: true

module Decidim
  module Demographics
    class Demographic < ApplicationRecord
      belongs_to :user, foreign_key: :decidim_user_id, class_name: "Decidim::User"
      belongs_to :organization, foreign_key: :decidim_organization_id, class_name: "Decidim::Organization"

      AVAILABLE_GENDERS = %w(man woman non_binary).freeze
      AGE_GROUPS = ["15-24","25-39","40-54","55-69","70+"].freeze
      MEMBER_STATES = %w(
        austrian
        belgian
        bulgarian
        croat
        cypriote
        czech
        dane
        estonian
        finn
        french
        german
        greek
        hungarian
        irish
        italian
        latvian
        lithuanian
        luxembourger
        maltese
        dutch
        polish
        portuguese
        romanian
        slovak
        slovenian
        spanish
        swede
        other
      ).freeze
      PROFESSIONAL_CATEGORIES = %w(self-employed manager  manual-worker professional-worker house-person unemployed retired student other).freeze
      LIVING_CONDITIONS = %w(rural small large unknown).freeze

      # DataPortability compatibility
      def self.user_collection(user)
        where(decidim_user_id: user.id)
      end

      def self.export_serializer
        Decidim::Demographics::DataPortabilityDemographicSerializer
      end

      # Returns a collection of images scoped by User.
      # Returns nil for default.
      def self.data_portability_images(_user)
        nil
      end

      %w(age background gender postal_code).each do |field|
        define_method(field) do
          Decidim::AttributeEncryptor.decrypt(data[__method__.to_s]) || ""
        end
      end

      def nationalities
        Decidim::AttributeEncryptor.decrypt(data["nationalities"]) || []
      end

      def self.not_set_for_user?(user)
        find_by(decidim_user_id: user).nil?
      end
    end
  end
end
