# frozen_string_literal: true

module Decidim
  module Verifications
    module ApplicationHelper
      def announcement_title(authorization)
        return t("decidim.verifications.id_documents.authorizations.edit.being_reviewed") unless authorization.rejected?

        body = content_tag :ul do
          items = content_tag(:li, t("decidim.verifications.id_documents.authorizations.edit.rejection_correctness"))
          items += content_tag(:li, t("decidim.verifications.id_documents.authorizations.edit.rejection_clarity")).html_safe
          items
        end

        {
          title: t("decidim.verifications.id_documents.authorizations.edit.rejection_notice"),
          body:
        }
      end

      def authorization_display_data(authorization)
        { title: t("#{authorization.name}.name", scope: "decidim.authorization_handlers") }
      end

      def granted_authorization_display_data(authorization, redirect_url = nil)
        authorization_display_data(authorization).merge(
          url: granted_authorization_url(authorization, redirect_url),
          remote_url: granted_authorization_remote_url(authorization),
          auth_icon: "checkbox-circle-line",
          is_granted: true,
          explanation: granted_authorization_explanation(authorization),
          button_text: granted_authorization_button_text(authorization)
        )
      end

      def granted_authorization_url(authorization, redirect_url = nil)
        return if authorization.renewable?
        return unless authorization.expired?

        url_params = { redirect_url: }.compact
        authorization_method(authorization).root_path(**url_params)
      end

      def granted_authorization_remote_url(authorization)
        return unless authorization.renewable?

        renew_modal_authorizations_path(handler: authorization.name)
      end

      def authorizations_back_path(user, redirect_url: nil)
        return redirect_url if redirect_url == decidim_verifications.onboarding_pending_authorizations_path && pending_onboarding_action?(user)

        decidim_verifications.authorizations_path
      end

      def granted_authorization_explanation(authorization)
        expiration_timestamp = authorization.expires_at.presence && l(authorization.expires_at, format: :long_with_particles)
        if authorization.expired?
          t("expired_at", scope: "decidim.authorization_handlers", timestamp: expiration_timestamp)
        else
          "#{t("granted_at", scope: "decidim.authorization_handlers", timestamp: l(authorization.granted_at, format: :long_with_particles))}\
          #{t("expires_at", scope: "decidim.authorization_handlers", timestamp: expiration_timestamp) if expiration_timestamp.present?}"
        end
      end

      def granted_authorization_button_text(authorization)
        return t("authorizations.index.show_renew_info", scope: "decidim.verifications") if authorization.renewable?
        return unless authorization.expired?

        t("authorizations.index.expired_verification", scope: "decidim.verifications")
      end

      def pending_authorization_display_data(authorization, redirect_url = nil)
        url_params = { redirect_url: }.compact

        authorization_display_data(authorization).merge(
          url: authorization_method(authorization).resume_authorization_path(**url_params),
          auth_icon: "time-line",
          explanation: t("started_at", scope: "decidim.authorization_handlers", timestamp: l(authorization.updated_at, format: :long_with_particles)),
          button_text: t("authorizations.index.introduce_code", scope: "decidim.verifications")
        )
      end

      def unauthorized_method_display_data(method, redirect_url = nil)
        url_params = { redirect_url: }.compact

        {
          url: method.root_path(**url_params),
          auth_icon: method.icon,
          title: t("#{method.key}.name", scope: "decidim.authorization_handlers"),
          explanation: t("#{method.key}.explanation", scope: "decidim.authorization_handlers"),
          button_text: t("authorizations.index.subscribe", scope: "decidim.verifications")
        }
      end

      def onboarding_sections(onboarding_manager, redirect_url: nil, granted_authorizations: nil, pending_authorizations: nil, unauthorized_methods: nil)
        [
          [
            t("granted_verifications", scope: "decidim.verifications.authorizations.onboarding_pending"),
            onboarding_manager.filter_authorizations(granted_authorizations),
            :granted_authorization_display_data
          ],
          [
            t("pending_admin_approval_verifications", scope: "decidim.verifications.authorizations.onboarding_pending"),
            onboarding_manager.filter_authorizations(pending_authorizations),
            :pending_authorization_display_data
          ],
          [
            t("pending_verifications", scope: "decidim.verifications.authorizations.onboarding_pending"),
            onboarding_manager.filter_authorizations(unauthorized_methods),
            :unauthorized_method_display_data
          ]
        ].filter_map do |title, authorizations, presenter|
          { title:, items: authorizations.map { |authorization| send(presenter, authorization, redirect_url) } } if authorizations.present?
        end
      end
    end
  end
end
