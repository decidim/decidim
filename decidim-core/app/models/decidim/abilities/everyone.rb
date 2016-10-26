# frozen_string_literal: true
module Decidim
  module Abilities
    class Everyone
      include CanCan::Ability

      def initialize(_user)
        can :read, Decidim::ParticipatoryProcess
      end
    end
  end
end
