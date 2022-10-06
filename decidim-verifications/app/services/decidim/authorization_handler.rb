# frozen_string_literal: true

module Decidim
  # This is the base class for authorization handlers, all implementations
  # should inherit from it.
  # Each AuthorizationHandler is a form that will be used to check if the
  # authorization is valid or not. When it is valid a new authorization will
  # be created for the user.
  #
  # Feel free to use validations to assert fields against a remote API,
  # local database, or whatever.
  #
  # It also sets two default attributes, `user` and `handler_name`.
  class AuthorizationHandler < Form
    # The user that is trying to authorize, it's initialized with the
    # `current_user` from the controller.
    attribute :user, Decidim::User

    # The String name of the handler, should not be modified since it's used to
    # infer the class name of the authorization handler.
    attribute :handler_name, String

    validate :uniqueness

    # A unique ID to be implemented by the authorization handler that ensures
    # no duplicates are created. This uniqueness check will be skipped if
    # unique_id returns nil.
    def unique_id
      nil
    end

    # The attributes of the handler that should be exposed as form input when
    # rendering the handler in a form.
    #
    # Returns an Array of Strings.
    def form_attributes
      attributes.except("id", "user").keys
    end

    # The String partial path so Rails can render the handler as a form. This
    # is useful if you want to have a custom view to render the form instead of
    # the default view.
    #
    # Example:
    #
    #   A handler named Decidim::CensusHandler would look for its partial in:
    #   decidim/census/form
    #
    # Returns a String.
    def to_partial_path
      "#{handler_name.sub!(/_handler$/, "")}/form"
    end

    # Any data that the developer would like to inject to the `metadata` field
    # of an authorization when it's created. Can be useful if some of the
    # params the user sent with the authorization form want to be persisted for
    # future use.
    #
    # As a convention, an 'extras' key can be used to store information not
    # directly related with authorization. Thus, when rendering previous
    # verification data, on renewal, 'extras' is not rendered to the user.
    #
    # Returns a Hash.
    def metadata
      {}
    end

    #
    # Any data to be injected in the `verification_metadata` field of an
    # authorization when it's created. This data will be used for multi-step
    # verificaton workflows in order to confirm the authorization.
    #
    # Returns a Hash.
    def verification_metadata
      {}
    end

    #
    # An optional attachment to help out with verification.
    #
    def verification_attachment
      nil
    end

    # A serialized version of the handler's name.
    #
    # Returns a String.
    def self.handler_name
      name.demodulize.underscore
    end

    # Same as the class method but accessible from the instance.
    #
    # Returns a String.
    def handler_name
      self.class.handler_name
    end

    # Finds a handler class from a String. This is necessary when processing
    # the form data. It will only look for valid handlers that have also been
    # configured in `Decidim.authorization_handlers`.
    #
    # name - The String name of the class to find, usually in the same shape as
    # the one returned by `handler_name`.
    # params - An optional Hash with params to initialize the handler.
    #
    # Returns an AuthorizationHandler descendant.
    # Returns nil when no handlers could be found.
    def self.handler_for(name, params = {})
      return unless name

      manifest = Decidim.authorization_handlers.find { |m| m.name == name }
      return unless manifest

      manifest.form.constantize.from_params(params || {})
    end

    private

    def duplicates
      Authorization.where(
        user: User.where.not(id: user.id).where(organization: user.organization),
        name: handler_name,
        unique_id:
      )
    end

    def uniqueness
      return true if unique_id.nil? || duplicates.none?

      errors.add(:base, I18n.t("decidim.authorization_handlers.errors.duplicate_authorization"))

      false
    end
  end
end
