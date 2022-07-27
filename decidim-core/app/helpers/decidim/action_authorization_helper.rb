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

    # rubocop: disable Metrics/PerceivedComplexity
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
      resource = html_options.delete(:resource)
      permissions_holder = html_options.delete(:permissions_holder)

      if !current_user
        html_options = clean_authorized_to_data_open(html_options)

        html_options["data-open"] = "loginModal"
        url = "#"
      elsif action && !action_authorized_to(action, resource:, permissions_holder:).ok?
        html_options = clean_authorized_to_data_open(html_options)

        html_options["data-open"] = "authorizationModal"
        html_options["data-open-url"] = modal_path(action, resource)
        url = "#"
      end

      html_options["onclick"] = "event.preventDefault();" if url == ""

      if block
        send("#{tag}_to", url, html_options, &body)
      else
        send("#{tag}_to", body, url, html_options)
      end
    end
    # rubocop: enable Metrics/PerceivedComplexity

    def modal_path(action, resource)
      resource_params = if resource
                          { resource_name: resource.resource_manifest.name, resource_id: resource.id }
                        else
                          {}
                        end
      if current_component.present?
        decidim.authorization_modal_path(authorization_action: action, component_id: current_component&.id, **resource_params)
      else
        decidim.free_resource_authorization_modal_path(authorization_action: action, **resource_params)
      end
    end

    def clean_authorized_to_data_open(html_options)
      html_options.delete(:"data-open")
      html_options.delete(:"data-open-url")

      [:data, "data"].each do |key|
        next unless html_options[key].is_a?(Hash)

        html_options[key].delete(:open)
        html_options[key].delete("open")
        html_options[key].delete(:open_url)
        html_options[key].delete("open_url")
        html_options[key].delete(:"open-url")
        html_options[key].delete("open-url")
      end

      html_options
    end
  end
end
