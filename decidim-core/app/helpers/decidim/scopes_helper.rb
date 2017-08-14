# frozen_string_literal: true

module Decidim
  # A Helper to render scopes, including a global scope, for forms.
  module ScopesHelper
    Option = Struct.new(:id, :name)

    # Check whether the resource has a visible scope or not.
    #
    # Returns boolean.
    def has_visible_scopes?(resource)
      current_participatory_process.scopes_enabled? && !current_participatory_process.scope.present? && resource.scope.present?
    end
  end
end
