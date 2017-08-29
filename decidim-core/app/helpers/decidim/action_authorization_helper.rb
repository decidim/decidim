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
        html_options["data-toggle"] = current_user ? "#{action.to_s.underscore}AuthorizationModal" : "loginModal"
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
        html_options["data-toggle"] = current_user ? "#{action.to_s.underscore}AuthorizationModal" : "loginModal"
        url = ""
      end

      html_options["onclick"] = "event.preventDefault();" if url == ""

      if block_given?
        button_to(url, html_options, &body)
      else
        button_to(body, url, html_options)
      end
    end

    private

    def current_user_authorized?(action)
      current_user && action_authorization(action).ok?
    end
  end
end
