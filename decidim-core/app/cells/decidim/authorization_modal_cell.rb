# frozen_string_literal: true

module Decidim
  class AuthorizationModalCell < Decidim::ViewModel
    include LayoutHelper

    delegate :authorize_action_path, to: :controller

    alias authorizations model

    def base_code
      @base_code ||= authorizations.global_code || :missing
    end

    def title
      code = current_user_not_verifiable? ? "unconfirmed" : base_code

      t("#{code}.title", scope:)
    end

    def verifications
      if current_user_not_verifiable?
        [{
          messages: [t("unconfirmed.explanation_html", scope:, email: current_user.email), t("unconfirmed.confirmation_instructions", scope:)],
          cta: { type: :a, text: t("unconfirmed.request_confirmation_instructions", scope:), url: new_confirmation_path(Decidim::User) }
        }]
      else
        authorizations.statuses.each_with_object([]) do |status, statuses|
          next if status.ok?
          next if authorizations.global_code && status.code != base_code

          statuses << { messages: status_messages(status), cta: status_cta(status), fields: status_fields(status) }
        end
      end
    end

    private

    def current_user_not_verifiable?
      @current_user_not_verifiable ||= current_user && !current_user.verifiable?
    end

    def scope
      "decidim.authorization_modals.content"
    end

    def status_messages(status)
      [t(
        "#{status.code}.explanation",
        authorization: t("#{status.handler_name}.name", scope: "decidim.authorization_handlers"),
        scope:
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
          scope:
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
            scope:
          ),
          url: authorize_action_path(status.handler_name)
        }
      else
        {
          type: :button,
          text: t("#{status.code}.ok", scope:),
          data: { "dialog-close": "authorizationModal" }
        }
      end
    end
  end
end
