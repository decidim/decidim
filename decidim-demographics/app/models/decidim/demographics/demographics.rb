# frozen_string_literal: true

module Decidim
  module Demographics
    class Demographics
      AVAILABLE_GENDERS = %w(man woman non_binary)
      AGE_GROUPS = [ "Under 15", "15-19", "20-24", "25-29", "30-34", "35-39", "40-44", "45-49", "50-54", "55-59", "60-64", "65-69", "70-74", "75-79", "80 and more"]
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
  )
      PROFESSIONAL_CATEGORIES = ["Self-employed", "Manager", "White collar", "Manual worker", "House worker", "Unemployed", "Retired", "Student"]

    end
  end
end
