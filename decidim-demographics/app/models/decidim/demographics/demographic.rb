# frozen_string_literal: true

module Decidim
  module Demographics
    class Demographic < ApplicationRecord
      belongs_to :user, foreign_key: :decidim_user_id, class_name: "Decidim::User"
      belongs_to :organization, foreign_key: :decidim_organization_id, class_name: "Decidim::Organization"

      AVAILABLE_GENDERS = %w(man woman non_binary).freeze
      AGE_GROUPS = ["15-24", "25-39", "40-54", "55-69", "70+"].freeze
      MEMBER_CITIZENSHIPS = %w(
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
      MEMBER_COUNTRIES = %w(
        austria
        belgium
        bulgaria
        croatia
        cyprus
        czechia
        denmark
        estonia
        finland
        france
        germany
        greece
        hungary
        ireland
        italy
        latvia
        lithuania
        luxembourg
        malta
        netherlands
        poland
        portugal
        romania
        slovakia
        slovenia
        spain
        sweden
        other
      ).freeze
      PROFESSIONAL_CATEGORIES = %w(self-employed manager manual-worker professional-worker house-person unemployed retired student other).freeze
      LIVING_CONDITIONS = %w(rural small large unknown).freeze
      EDUCATION_OPTIONS = %w(under_15 under_20 20_plus still_studying no_full_time_education refusal).freeze
      ATTENDED_BEFORE = %w(affirmative negative unknown).freeze

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

      %w( gender
          age
          nationalities
          other_nationalities
          residences
          other_residences
          living_condition
          current_occupations
          education_age_stop
          other_ocupations
          attended_before
          newsletter_sign_in).each do |field|
        define_method(field) do
          data[__method__.to_s] || ""
        end
      end

      def self.not_set_for_user?(user)
        find_by(decidim_user_id: user).nil?
      end
    end
  end
end
