# frozen_string_literal: true

module Decidim
  module ActionAuthorizationHelper
    # Public: Emulates a `link_to` but conditionally renders a popup modal
    # blocking the action in case the user isn't allowed to perform it.
    #
    # action     - The name of the action to authorize against.
    # *arguments - A regular set of arguments that would be provided to
    #              `link_to`.
    #
    # Returns a String with the link.
    def action_authorized_link_to(action, *arguments, &block)
      authorized_to(:link, action, arguments, block)
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
      authorized_to(:button, action, arguments, block)
    end

    # Public: Emulates a `link_to` but conditionally renders a popup modal
    # blocking the action in case the user isn't logged id.
    #
    # *arguments - A regular set of arguments that would be provided to
    #              `link_to`.
    #
    # Returns a String with the link.
    def logged_link_to(*arguments, &block)
      authorized_to(:link, nil, arguments, block)
    end

    # Public: Emulates a `button_to` but conditionally renders a popup modal
    # blocking the action in case the user isn't logged id.
    #
    # *arguments - A regular set of arguments that would be provided to
    #              `button_to`.
    #
    # Returns a String with the button.
    def logged_button_to(*arguments, &block)
      authorized_to(:button, nil, arguments, block)
    end

    private

    def authorized_to(tag, action, arguments, block)
      if block
        body = block
        url = arguments[0]
        html_options = arguments[1]
      else
        body = arguments[0]
        url = arguments[1]
        html_options = arguments[2]
      end

      html_options ||= {}

      if !current_user
        html_options["data-open"] = "loginModal"
        url = ""
      elsif action && !action_authorized_to(action)
        html_options["data-open"] = "authorizationModal"
        html_options["data-open-url"] = modal_path(action)
        url = ""
      end

      html_options["onclick"] = "event.preventDefault();" if url == ""

      if block
        send("#{tag}_to", url, html_options, &body)
      else
        send("#{tag}_to", body, url, html_options)
      end
    end

    def action_authorized_to(action)
      ::Decidim::ActionAuthorizer.new(current_user, current_component, action).authorize.ok?
    end

    def modal_path(action)
      decidim.authorization_modal_path(authorization_action: action, component_id: current_component.id)
    end
  end
end
