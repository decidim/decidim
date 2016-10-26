# frozen_string_literal: true
module Decidim
  module Abilities
    # Defines the base abilities for any user. Guest users will use these too.
    # Intended to be used with `cancancan`.
    class Everyone
      include CanCan::Ability

      def initialize(_user)
        can :read, Decidim::ParticipatoryProcess
      end
    end
  end
end
