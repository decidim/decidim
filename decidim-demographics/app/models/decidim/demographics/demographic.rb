# frozen_string_literal: true

module Decidim
  module Demographics
    class Demographic < ApplicationRecord
      belongs_to :user, foreign_key: :decidim_user_id, class_name: "Decidim::User"

      AVAILABLE_GENDERS = %w(man woman non_binary).freeze
      AGE_GROUPS = ["< 15", "15-19", "20-24", "25-29", "30-34", "35-39", "40-44", "45-49", "50-54", "55-59", "60-64", "65-69", "70-74", "75-79", "80 +"].freeze
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
      PROFESSIONAL_CATEGORIES = ["Self-employed", "Manager", "White collar", "Manual worker", "House worker", "Unemployed", "Retired", "Student"].freeze
    end
  end
end
