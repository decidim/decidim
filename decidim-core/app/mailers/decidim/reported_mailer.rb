# frozen_string_literal: true

module Decidim
  # A custom mailer for sending notifications to an admin when a report is created..
  class ReportedMailer < Decidim::ApplicationMailer
    helper Decidim::ResourceHelper
    helper Decidim::TranslationsHelper

    helper_method :reported_content_url, :manage_moderations_url, :author_profile_url

    def report(user, report)
      with_user(user) do
        @report = report
        @participatory_space = @report.moderation.participatory_space
        @organization = user.organization
        @user = user
        @author = @report.moderation.reportable.try(:creator_identity) || @report.moderation.reportable.try(:author)
        content_title = @report.moderation.reportable.try(:title)
        content_body = @report.moderation.reportable.try(:body)
        @content = { title: content_title, body: content_body }.compact
        @content_id = @report.moderation.reportable.id
        @original_language = original_language_for(content_title) || original_language_for(content_body)
        subject = I18n.t("report.subject", scope: "decidim.reported_mailer")
        mail(to: user.email, subject: subject)
      end
    end

    def hide(user, report)
      with_user(user) do
        @report = report
        @participatory_space = @report.moderation.participatory_space
        @organization = user.organization
        @user = user
        subject = I18n.t("hide.subject", scope: "decidim.reported_mailer")
        mail(to: user.email, subject: subject)
      end
    end

    private

    def reported_content_url
      @reported_content_url ||= @report.moderation.reportable.reported_content_url
    end

    def manage_moderations_url
      @manage_moderations_url ||= EngineRouter.admin_proxy(@participatory_space).moderations_url(host: @organization.host)
    end

    def author_profile_url
      @author_profile_url ||= @author.is_a?(Decidim::UserBaseEntity) ? decidim.profile_url(@author.nickname, host: @organization.host) : nil
    end

    def original_language_for(field)
      return if field.nil?
      return field.except("machine_translations").keys.first if field.is_a?(Hash) && field.except("machine_translations").keys.count == 1

      @organization.default_locale
    end
  end
end
