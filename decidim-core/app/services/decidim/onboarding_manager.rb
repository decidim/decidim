# frozen_string_literal: true

module Decidim
  # This class is used to manage the onboarding funnel for users that
  # intended to perform an action in the platform but it requires some
  # verification steps to be completed.
  #
  # The flow is as follows:
  #
  # 1. A visitor (logged out) tries to perform an action that requires to be logged in
  # 2. The intended action is stored in a cookie (onboarding key)
  # 3. The visitor logs in and the onboarding cookie data is merged into the User#extended_data column.
  # 4. After logging in, the user is redirected to the onboarding authorizations page
  #    (first_login page that will be renamed) if there is any pending action stored in
  #    the User#extended_data column
  # 5. The user completes the required authorizations
  # 6. When the onboarding authorizations page detects that all the verification steps have been
  #    completed, it will remove the pending action from the User#extended_data column and redirect
  #    the user to the intended action.
  #
  class OnboardingManager
    attr_reader :user

    def initialize(user)
      @user = user
    end

    # Checks if the onboarding data has an action and a model.
    #
    # Returns a boolean
    def valid?
      action.present? && model.present?
    end

    # Returns the action to be performed.
    #
    # Returns a string
    def action
      onboarding_action
    end

    # Checks if there is any pending action for the user.
    #
    # Returns a boolean
    def pending_action?
      onboarding_data.present?
    end

    # Checks if the user has completed all the required authorizations.
    #
    # active_authorization_methods - A list of the active authorization methods for the user.
    #
    # Returns a boolean
    def finished_verifications?(active_authorization_methods)
      (authorization_handlers - active_authorization_methods).empty?
    end

    # Removes the pending action from the user's extended_data.
    #
    # Returns nothing
    def remove_pending_action!
      extended_data = user.extended_data
      extended_data.delete("onboarding")
      user.update!(extended_data:)
    end

    # Returns the model related to the action in the onboarding process.
    #
    # Returns an ActiveRecord model
    def model
      @model ||= GlobalID::Locator.locate(onboarding_model)
    end

    # Returns the model name related to the action in the onboarding process.
    #
    # Returns a string
    def model_name
      return unless valid?

      @model_name ||= model.class.model_name
    end

    # Filters the given authorizations that are required for the onboarding process.
    #
    # authorizations - An array of Decidim::Authorization objects
    #
    # Returns an array of Decidim::Authorization objects
    def filter_authorizations(authorizations)
      authorizations.select { |authorization| authorization_handlers.include?(authorization.name) }
    end

    private

    # Returns the permissions for the action and model in the onboarding process.
    #
    # Returns a hash
    def permissions
      @permissions ||= model&.permissions&.fetch(action, nil) || component&.permissions&.fetch(action, nil)
    end

    # Returns the authorization handlers for the action and model in the onboarding process.
    #
    # Returns an array of strings
    def authorization_handlers
      return unless permissions

      permissions["authorization_handlers"]&.keys&.map(&:to_s) || []
    end

    # Returns the model component
    #
    # Returns a Decidim::Component
    def component
      model.component
    end

    # Returns the onboarding data from the user's extended_data related to the model in gid format.
    #
    # Returns a string
    def onboarding_model
      onboarding_data["model"]
    end

    # Returns the onboarding data from the user's extended_data related to the action.
    #
    # Returns a string
    def onboarding_action
      onboarding_data["action"]
    end

    # Returns the onboarding data from the user's extended_data.
    #
    # Returns a hash
    def onboarding_data
      user.extended_data["onboarding"] || {}
    end
  end
end
