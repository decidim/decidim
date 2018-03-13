# frozen_string_literal: true

module Decidim
  module ActionAuthorizationHelper
    # Public: Renders a modal that explains why she can't perform an action,
    # if that's the case. The modal isn't shown by default, and it's usually
    # triggered by `action_authorized_link_to` or `action_authorized_button_to`.
    #
    # action - The action to authenticate against.
    #
    # Returns a String with the modal.
    def action_authorization_modal(action)
      render partial: "decidim/shared/action_authorization_modal",
             locals: { action: action.to_s }
    end

    # Public: Emulates a `link_to` but conditionally renders a popup modal
    # blocking the action in case the user isn't allowed to perform it.
    #
    # action     - The name of the action to authorize against.
    # *arguments - A regular set of arguments that would be provided to
    #              `link_to`.
    #
    # Returns a String with the link.
    def action_authorized_link_to(action, *arguments, &block)
      if block_given?
        body = block
        url = arguments[0]
        html_options = arguments[1]
      else
        body = arguments[0]
        url = arguments[1]
        html_options = arguments[2]
      end

      unless current_user_authorized?(action)
        html_options ||= {}
        html_options["onclick"] = "event.preventDefault();"
        html_options["data-open"] = current_user ? "#{action.to_s.underscore}AuthorizationModal" : "loginModal"
        url = ""
      end

      if block_given?
        link_to(url, html_options, &body)
      else
        link_to(body, url, html_options)
      end
    end

    # Public: Emulates a `button_to` but conditionally renders a popup modal
    # blocking the action in case the user isn't allowed to perform it.
    #
    # action     - The name of the action to authorize against.
    # *arguments - A regular set of arguments that would be provided to
    #              `button_to`.
    #
    # Returns a String with the button.
    def action_authorized_button_to(action, *arguments, &block)
      if block_given?
        body = block
        url = arguments[0]
        html_options = arguments[1] || {}
      else
        body = arguments[0]
        url = arguments[1]
        html_options = arguments[2] || {}
      end

      unless current_user_authorized?(action)
        html_options["data-open"] = current_user ? "#{action.to_s.underscore}AuthorizationModal" : "loginModal"
        url = ""
      end

      html_options["onclick"] = "event.preventDefault();" if url == ""

      if block_given?
        button_to(url, html_options, &body)
      else
        button_to(body, url, html_options)
      end
    end

    # Public: Authorizes an action of a feature given an action name.
    #
    # action_name  - The action name to authorize. Actions are set up on the
    #                feature's permissions panel.
    # redirect_url - Url to be redirected to when the authorization is finished.
    def authorize_action!(action_name, redirect_url: nil)
      status = action_authorization(action_name)

      return if status.ok?
      raise Unauthorized if status.code == :unauthorized

      redirect_to authorize_action_path(action_name, redirect_url: redirect_url)
    end

    # Public: Returns the authorization object for an authorization.
    #
    # action_name - The action to authorize against.
    #
    # Returns an ActionAuthorizer::AuthorizationStatus
    def action_authorization(action_name)
      @action_authorizations ||= {}

      @action_authorizations[action_name] = _action_authorizer(action_name).authorize
    end

    # Public: Returns the authorization path for a failed authorization with
    # the populated redirect url.
    #
    # action_name - The action name to authorize against.
    # redirect_url - The url to redirect to when finished.
    #
    # Returns a String.
    def authorize_action_path(action_name, redirect_url: nil)
      redirect_url ||= request.path

      action_authorization(action_name).current_path(redirect_url: redirect_url)
    end

    def _action_authorizer(action_name)
      ::Decidim::ActionAuthorizer.new(current_user, current_component, action_name)
    end

    class Unauthorized < StandardError; end

    private

    def current_user_authorized?(action)
      current_user && action_authorization(action).ok?
    end
  end
end
