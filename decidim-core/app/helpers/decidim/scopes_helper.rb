# frozen_string_literal: true

module Decidim
  # A Helper to render scopes, including a global scope, for forms.
  module ScopesHelper
    Option = Struct.new(:id, :name)

    # Public: Returns a collection of the given "scopable object" scopes,
    # prepending a global scope. The global scope is at the beginning because
    # it's easier to be found there. Use this helper in places like `select`
    # elements in forms.
    #
    # scopable - an object including the Decidim::Scopable concern.
    #
    # Returns an Array.
    def subscopes_for(scopable)
      [Option.new("", I18n.t("decidim.scopes.global"))] +
        scopable.subscopes.map do |scope|
          Option.new(scope.id, translated_attribute(scope.name))
        end
    end
  end
end
