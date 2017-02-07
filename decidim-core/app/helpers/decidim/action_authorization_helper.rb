# encoding: utf-8
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
             locals: { action: action }
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
        body = capture(block)
        url = arguments[0]
        html_options = arguments[1] || {}
      else
        body = arguments[0]
        url = arguments[1]
        html_options = arguments[2] || {}
      end

      unless action_authorization(action).ok?
        html_options["onclick"] = "event.preventDefault();"
        html_options["data-toggle"] = "#{action.to_s.underscore}AuthorizationModal"
        url = ""
      end

      link_to(body, url, html_options, &block)
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
        body = capture(block)
        url = arguments[0]
        html_options = arguments[1] || {}
      else
        body = arguments[0]
        url = arguments[1]
        html_options = arguments[2] || {}
      end

      unless action_authorization(action).ok?
        html_options["onclick"] = "event.preventDefault();"
        html_options["data-toggle"] = "#{action.to_s.underscore}AuthorizationModal"
        url = ""
      end

      button_to(body, url, html_options, &block)
    end
  end
end
