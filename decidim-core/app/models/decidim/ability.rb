# frozen_string_literal: true
module Decidim
  class Ability
    include CanCan::Ability

    def initialize(user)
      Decidim.abilities.each do |ability|
        merge ability.new(user)
      end
    end
  end
end
