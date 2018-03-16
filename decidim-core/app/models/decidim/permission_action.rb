# frozen_string_literal: true

module Decidim
  # This class encapsulates an action, which will be used by the
  # permissions system to check if the user is allowed to perform it.
  #
  # It consists of a `scope` (which will typically be either `:public` or
  # `:admin`), the name of the `:action` that is being performed and the
  # `:subject` of the action.
  class PermissionAction
    # action - a Symbol representing the action being performed
    # scope - a Symbol representing the scope of the action
    # subject - a Symbol representing the subject of the action
    def initialize(action:, scope:, subject:)
      @action = action
      @scope = scope
      @subject = subject
    end

    attr_reader :action, :scope, :subject
  end
end
