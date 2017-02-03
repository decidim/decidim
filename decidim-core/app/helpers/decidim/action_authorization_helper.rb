# encoding: utf-8
# frozen_string_literal: true
module Decidim
  module ActionAuthorizationHelper
    def action_authorization_modal(action)
      render partial: "decidim/shared/action_authorization_modal",
             locals: { action: action }
    end

    def action_authorized_link_to(action, *arguments, &block)
      html_options = if block_given?
                  arguments[1]
                else
                  arguments[2]
                end

      unless action_authorization(action).ok?
        html_options["onclick"] = "event.preventDefault();"
        html_options["data-toggle"] = "#{action.to_s.underscore}AuthorizationModal"
      end

      link_to(*arguments, &block)
    end

    def action_authorized_button_to(action, *arguments, &block)
      html_options = if block_given?
                       arguments[1]
                     else
                       arguments[2]
                     end

      unless action_authorization(action).ok?
        html_options["onclick"] = "event.preventDefault();"
        html_options["data-toggle"] = "#{action.to_s.underscore}AuthorizationModal"
      end

      button_to(*arguments, &block)
    end
  end
end
