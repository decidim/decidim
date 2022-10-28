# frozen_string_literal: true

module Decidim
  class AuthorizationModalsController < Decidim::ApplicationController
    helper_method :authorizations, :authorize_action_path, :status_messages, :status_fields, :status_cta
    layout false

    def show; end

    private

    def resource
      @resource ||= if params[:resource_name] && params[:resource_id]
                      manifest = Decidim.find_resource_manifest(params[:resource_name])
                      manifest&.resource_scope(current_component)&.find_by(id: params[:resource_id])
                    end
    end

    def current_component
      @current_component ||= Decidim::Component.find(params[:component_id])
    end

    def authorization_action
      @authorization_action ||= params[:authorization_action]
    end

    def authorize_action_path(handler_name)
      authorizations.status_for(handler_name).current_path(redirect_url: URI(request.referer).path)
    end

    def authorizations
      @authorizations ||= action_authorized_to(authorization_action, resource:)
    end

    def status_messages(status)
      [t(
        "#{status.code}.explanation",
        authorization: t("#{status.handler_name}.name", scope: "decidim.authorization_handlers"),
        scope: "decidim.authorization_modals.content"
      )].tap do |messages|
        [status.data[:extra_explanation]].flatten.compact.each do |extra_explanation|
          messages << t(extra_explanation[:key], **extra_explanation[:params])
        end
      end
    end

    def status_fields(status)
      return [] if status.data[:fields].blank?

      status.data[:fields].map do |field, value|
        t(
          "#{status.code}.invalid_field",
          field: t("#{status.handler_name}.fields.#{field}", scope: "decidim.authorization_handlers"),
          value: value ? "(#{value})" : "",
          scope: "decidim.authorization_modals.content"
        )
      end
    end

    def status_cta(status)
      if status.data[:action].present?
        {
          type: :a,
          text: t(
            "#{status.code}.#{status.data[:action]}",
            authorization: t("#{status.handler_name}.name", scope: "decidim.authorization_handlers"),
            scope: "decidim.authorization_modals.content"
          ),
          url: authorize_action_path(status.handler_name)
        }
      else
        {
          type: :button,
          text: t("#{status.code}.ok", scope: "decidim.authorization_modals.content"),
          data: { "dialog-close": "authorizationModal" }
        }
      end
    end
  end
end
