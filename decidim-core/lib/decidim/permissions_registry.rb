# frozen_string_literal: true

module Decidim
  #
  # Takes care of holding and accessing `Permission`s classes.
  #
  module PermissionsRegistry

    REGISTRY= Hash.new([])

    # Returns the registered array of `Permissions` for the given `artifact`.
    #
    # +artifact+ is expected to be the class or module that delcares `NeedsPermission.permission_class_chain`.
    def self.chain_for(artifact)
      REGISTRY[artifact]
    end

  end
end