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
  # 4. After logging in, the user is redirected to the onboarding pending authorizations page
  #    if there is any pending action stored in the User#extended_data column
  # 5. The user completes the required authorizations
  # 6. When the onboarding authorizations page detects that all the verification steps have been
  #    completed, it will remove the pending action from the User#extended_data column and redirect
  #    the user to the intended action.
  #
  class OnboardingManager
    # The same key is set in onboarding_pending_action js file to manage the
    # onboarding data in the cookie
    DATA_KEY = "onboarding"

    attr_reader :user

    def initialize(user)
      @user = user
    end

    delegate :ephemeral?, to: :user

    # Checks if the onboarding data has an action and a model.
    #
    # Returns a boolean
    def valid?
      return if action.blank?

      permissions_holder.present?
    end

    # Returns the action to be performed.
    #
    # Returns a string
    def action
      onboarding_action
    end

    # Returns the translation of the action to be performed if translation
    # is found, otherwise the untranslated literal action key
    #
    # Returns a string
    def action_text
      @action_text ||= if component && I18n.exists?("#{component.manifest.name}.actions.#{action}", scope: "decidim.components")
                         I18n.t("#{component.manifest.name}.actions.#{action}", scope: "decidim.components")
                       elsif permissions_holder.respond_to?(:resource_manifest) &&
                             I18n.exists?("#{permissions_holder.resource_manifest.name}.actions.#{action}", scope: "decidim.resources")
                         I18n.t("#{permissions_holder.resource_manifest.name}.actions.#{action}", scope: "decidim.resources")
                       else
                         action
                       end
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
    def finished_verifications?(authorization_methods = active_authorization_methods)
      (authorization_handlers - authorization_methods).empty?
    end

    # Returns the model related to the action in the onboarding process.
    #
    # Returns an ActiveRecord model
    def model
      return if onboarding_model.blank?

      @model ||= GlobalID::Locator.locate(onboarding_model)
    end

    # Returns the permissions_holder if present related to the action in the
    # onboarding process.
    #
    # Returns an ActiveRecord model
    def permissions_holder
      return model if onboarding_permissions_holder.blank?

      @permissions_holder ||= GlobalID::Locator.locate(onboarding_permissions_holder)
    end

    # Returns the model name related to the action in the onboarding process.
    #
    # Returns a string
    def model_name
      return unless valid?

      @model_name ||= (model.presence || permissions_holder).class.model_name
    end

    # Returns the resource title associated to the action. If the model is defined
    # its title is used, if not the permissions holder title
    #
    # Returns a translations Hash or a String
    def model_title
      return unless valid?

      @model_title ||= begin
        resource = model.presence || permissions_holder

        method = [:title, :name].find { |m| resource.respond_to?(m) }

        resource.send(method) if method
      end
    end

    # Filters the given authorizations that are required for the onboarding process.
    #
    # authorizations - An array of Decidim::Authorization objects
    #
    # Returns an array of Decidim::Authorization objects
    def filter_authorizations(authorizations)
      filtered_authorizations = authorizations.select { |authorization| authorization_handlers.include?(authorization.name) }

      # By calling authorize on each authorization the path generated for each
      # one will include the specific options of the action if available
      filtered_authorizations.each do |authorization|
        next unless authorization.is_a? Decidim::Verifications::Adapter

        authorization.authorize(nil, permissions.dig("authorization_handlers", authorization.name, "options") || {}, model, permissions_holder)
      end
      filtered_authorizations
    end

    # Returns a hash which can be passed to action_authorized_to helper method
    # to determine the permissions status of the action
    #
    # Returns a Hash
    def action_authorized_resources
      return {} unless valid?

      {
        resource: model,
        permissions_holder: onboarding_permissions_holder.presence && permissions_holder
      }
    end

    # Returns the path to redirect after finishing the verification process. The path
    # can be obtained from the user onboarding redirect_path data or if a resource is
    # present using a ResourceLocatorPresenter
    #
    # Returns a String
    def finished_redirect_path
      @finished_redirect_path ||= onboarding_data["redirect_path"].presence || model_path
    end

    def root_path
      component_path || Decidim::Core::Engine.routes.url_helpers.root_path
    end

    def component_path
      return if component.blank?

      EngineRouter.main_proxy(component).root_path
    end

    def authorization_path
      @authorization_path ||= onboarding_data["authorization_path"].presence
    end

    def expired?
      return unless ephemeral?

      session_duration > Decidim.config.expire_session_after.to_i
    end

    # Time in seconds since the last login or creation of the user
    #
    # Returns an Integer
    def session_duration
      Time.current.to_i - (user.last_sign_in_at || user.created_at).to_i
    end

    # This method is used to determine if an ephemeral user has an onboarding
    # page to be redirected or only an authorization is required to complete the
    # verification
    #
    # Returns a Boolean
    def available_authorization_selection_page?
      return true unless valid? && ephemeral?

      authorization_handlers.count > 1
    end

    private

    def active_authorization_methods
      @active_authorization_methods ||= Verifications::Authorizations.new(organization: user.organization, user:).pluck(:name)
    end

    # Returns the permissions for the action and model in the onboarding process.
    #
    # Returns a hash
    def permissions
      @permissions ||= permissions_holder&.permissions&.fetch(action, nil) || component&.permissions&.fetch(action, nil)
    end

    # Returns the authorization handlers for the action and model in the onboarding process.
    #
    # Returns an array of strings
    def authorization_handlers
      return [] unless permissions

      permissions["authorization_handlers"]&.keys&.map(&:to_s) || []
    end

    # Returns the model component or the permissions holder when it is a component.
    #
    # Returns a Decidim::Component
    def component
      return permissions_holder if permissions_holder.is_a?(Decidim::Component)
      return if model.blank?
      return unless model.respond_to?(:component)

      model.component
    end

    # Returns the onboarding data from the user's extended_data related to the model in gid format.
    #
    # Returns a string
    def onboarding_model
      onboarding_data["model"]
    end

    # Returns the onboarding data from the user's extended_data related to the permissions_holder
    # in gid format. This attribute is optional and may not be present
    #
    # Returns a string
    def onboarding_permissions_holder
      onboarding_data["permissions_holder"]
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
      user.extended_data[DATA_KEY] || {}
    end

    # Returns the path associated to the model using ResourceLocatorPresenter. If model is not
    # present returns the root path
    #
    # Returns a String
    def model_path
      return Decidim::Core::Engine.routes.url_helpers.root_path if model.blank?

      ResourceLocatorPresenter.new(model).url
    rescue NoMethodError
      Decidim::Core::Engine.routes.url_helpers.root_path
    end
  end
end
