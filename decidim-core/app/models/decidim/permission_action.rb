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
      @state = nil
      @backtrace = []
    end

    attr_reader :action, :scope, :subject, :backtrace

    def allow!
      raise PermissionCannotBeDisallowedError, "Allowing a previously disallowed action is not permitted: #{inspect}" if @state == :disallowed

      @state = :allowed
    end

    def disallow!
      @state = :disallowed
    end

    def allowed?
      raise PermissionNotSetError, "Permission hasn't been allowed or disallowed yet: #{inspect}" if @state.blank?

      @state == :allowed
    end

    def trace(class_name, state)
      @backtrace << [class_name, state]
    end

    # Checks if this PermissionAction specifies the same +scope+, +action+ and
    # +subject+ thant the ones provided as arguments.
    def matches?(scope, action, subject)
      same = (self.action == action)
      same &&= (self.scope == scope)
      same &&= (self.subject == subject)
      same
    end

    def to_s
      "!#{self.class.name}<action: #{action}, scope: #{scope}, subject: #{subject}, state: #{@state}>"
    end

    class PermissionNotSetError < StandardError; end

    class PermissionCannotBeDisallowedError < StandardError; end
  end
end
