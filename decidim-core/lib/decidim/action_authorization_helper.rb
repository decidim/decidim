# frozen_string_literal: true

module Decidim
  module ActionAuthorizationHelper
    # Public: Emulates a `link_to` but conditionally renders a popup modal
    # blocking the action in case the user is not allowed to perform it.
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
    # blocking the action in case the user is not allowed to perform it.
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
    # blocking the action in case the user is not logged id.
    #
    # *arguments - A regular set of arguments that would be provided to
    #              `link_to`.
    #
    # Returns a String with the link.
    def logged_link_to(*arguments, &block)
      authorized_to(:link, nil, arguments, block)
    end

    # Public: Emulates a `button_to` but conditionally renders a popup modal
    # blocking the action in case the user is not logged id.
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

      html_options = (html_options || {}).with_indifferent_access
      resource = html_options.delete(:resource)
      permissions_holder = html_options.delete(:permissions_holder)
      authorization_status = get_authorization_status(action, resource, permissions_holder)
      redirect_path = valid_redirect(url, tag:, method: html_options[:method])
      onboarding_options = onboarding_data_attributes(authorization_status, action, resource, permissions_holder, redirect_path)

      if sign_in_required?(authorization_status)
        html_options = clean_authorized_to_data_open(html_options.merge(onboarding_options))
        html_options["data-dialog-open"] = "loginModal"

        url = "#"
      elsif authorization_status&.ok? == false
        html_options = clean_authorized_to_data_open(html_options.merge(onboarding_options))
        if pending_steps?(authorization_status)
          tag = "link"
          html_options["method"] = "post"
          html_options.delete(:remote)
          url = decidim_verifications.renew_onboarding_data_authorizations_path
        else
          html_options["data-dialog-open"] = "authorizationModal"
          html_options["data-dialog-remote-url"] = modal_path(action, resource, html_options)
          url = "#"
        end
      end

      html_options["onclick"] = "event.preventDefault();" if url == ""

      if block
        send("#{tag}_to", url, html_options, &body)
      else
        send("#{tag}_to", content_tag(:span, body), url, html_options)
      end
    end
    # rubocop: enable Metrics/PerceivedComplexity

    def modal_path(action, resource, opts = {})
      if (default_path = opts.delete(:authorizations_modal_path)).present?
        return default_path
      end

      resource_params = if resource
                          { resource_name: resource.resource_manifest.name, resource_id: resource.id }
                        else
                          {}
                        end

      component = try(:current_component)
      if component.present?
        decidim.authorization_modal_path(authorization_action: action, component_id: component&.id, **resource_params)
      else
        decidim.free_resource_authorization_modal_path(authorization_action: action, **resource_params)
      end
    end

    def clean_authorized_to_data_open(html_options)
      return {} if html_options.blank?

      html_options.delete(:"data-dialog-open")
      html_options.delete(:"data-dialog-remote-url")

      [:data, "data"].each do |key|
        next unless html_options[key].is_a?(Hash)

        html_options[key].delete(:open)
        html_options[key].delete("open")
        html_options[key].delete(:open_url)
        html_options[key].delete("open_url")
        html_options[key].delete(:"open-url")
        html_options[key].delete("open-url")
        html_options[key].delete(:"dialog-open")
        html_options[key].delete(:"dialog-remote-url")
      end

      html_options
    end

    def get_authorization_status(action, resource, permissions_holder)
      return if action.blank?

      permissions_holder ||= resource.blank? ? try(:current_component) : nil
      return if permissions_holder.blank? && resource.try(:component).blank?

      action_authorized_to(action, resource:, permissions_holder:)
    end

    def pending_steps?(authorization_status)
      authorization_status.pending_authorizations_count.positive? && authorization_status.global_code != :unauthorized
    end

    def onboarding_data_attributes(authorization_status, action, resource, permissions_holder, redirect_path = nil)
      return {} if action.blank?
      return {} unless pending_steps?(authorization_status)

      permissions_holder ||= try(:current_component) if resource.blank?
      return {} if [resource, permissions_holder].all?(&:blank?)

      {
        "data-onboarding-model" => resource&.to_gid,
        "data-onboarding-permissions-holder" => permissions_holder&.to_gid,
        "data-onboarding-action" => action,
        "data-onboarding-redirect-path" => redirect_path
      }.compact
    end

    def valid_redirect(path, opts = {})
      return if opts[:tag]&.to_sym == :button
      return if path == "#"
      return if opts[:method].present? && opts[:method].to_s != "get"

      path
    end

    def sign_in_required?(authorization_status)
      return if current_user.present?

      !authorization_status&.ephemeral?
    end
  end
end
