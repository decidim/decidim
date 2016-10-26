# frozen_string_literal: true
module Decidim
  # Defines the abilities for a User. Intended to be used with `cancancan`.
  class Ability
    include CanCan::Ability

    def initialize(user)
      Decidim.abilities.each do |ability|
        merge ability.new(user)
      end
    end
  end
end
