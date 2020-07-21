# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # A concern with the components needed when you want a model to have a scope.
  #
  # The including model needs to implement the following interface:
  #
  #  @abstract An instance method that returns the id of the scope
  #  @method decidim_scope_id
  #    @return [Integer]
  #
  #  @abstract An instance method that states whether scopes are enabled or not
  #  @method scopes_enabled
  #    @return [Boolean]
  #
  #  @abstract An method that gives an associated organization
  #  @method organization
  #    @return [Decidim::Organization]
  #
  module Scopable
    extend ActiveSupport::Concern

    included do
      delegate :scopes, to: :organization

      validate :scope_belongs_to_organization
    end

    # Whether the resource has scopes enabled or not.
    #
    # Returns a boolean.
    def scopes_enabled?
      scopes_enabled
    end

    # Gets the children scopes of the object's scope.
    #
    # If it's global, returns the organization's top scopes.
    #
    # Returns an ActiveRecord::Relation.
    def subscopes
      scope ? scope.children : organization.top_scopes
    end

    # Whether the resource has subscopes or not.
    #
    # Returns a boolean.
    def has_subscopes?
      scopes_enabled? && subscopes.any?
    end

    # Whether the passed subscope is out of the resource's scope.
    #
    # Returns a boolean
    def out_of_scope?(subscope)
      scope && !scope.ancestor_of?(subscope)
    end

    # If any, gets the previous scope of the object.
    #
    #
    # Returns a Decidim::Scope
    def previous_scope
      return if versions.count <= 1

      Decidim::Scope.find_by(id: versions.last.reify.decidim_scope_id)
    end

    private

    # validation method for participatory spaces
    def scope_belongs_to_organization
      return if !scope || !organization

      errors.add(:scope, :invalid) unless organization.scopes.where(id: scope.id).exists?
    end

    # validation method for components
    def scope_belongs_to_participatory_space
      return if !scopes_enabled? || !participatory_space

      errors.add(:scope, :invalid) if participatory_space.out_of_scope?(scope)
    end
  end
end
