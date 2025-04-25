# frozen_string_literal: true

module Decidim
  # A custom mailer for sending notifications to an admin when a report is created.
  class ReportedMailer < Decidim::ApplicationMailer
    helper Decidim::ResourceHelper

    helper_method :reported_content_url, :report_url, :manage_moderations_url, :author_profile_url, :reported_content_cell

    def report(user, report)
      with_user(user) do
        @report = report
        @reportable = @report.moderation.reportable
        @participatory_space = @report.moderation.participatory_space
        @organization = user.organization
        @user = user
        @author = @reportable.try(:creator_identity) || @reportable.try(:author)
        @original_language = original_language(@reportable)
        subject = I18n.t("report.subject", scope: "decidim.reported_mailer")
        mail(to: user.email, subject:)
      end
    end

    # This is used when a user with special rights (like an administrator, a space administrator or a moderator) hides a resource
    def hidden_manually(user, report, current_user)
      with_user(user) do
        @report = report
        @participatory_space = @report.moderation.participatory_space
        @reportable = @report.moderation.reportable
        @organization = user.organization
        @user = user
        @moderator = current_user
        subject = I18n.t("hidden_manually.subject", scope: "decidim.reported_mailer", moderator: @moderator.name)
        mail(to: user.email, subject:)
      end
    end

    # This is meant to be used when a resource is hidden by an algorithm, such as the `decidim-ai` module, or the `Decidim.max_reports_before_hiding` feature.
    def hidden_automatically(user, report)
      with_user(user) do
        @report = report
        @participatory_space = @report.moderation.participatory_space
        @reportable = @report.moderation.reportable
        @organization = user.organization
        @user = user
        subject = I18n.t("hidden_automatically.subject", scope: "decidim.reported_mailer")
        mail(to: user.email, subject:)
      end
    end

    # See comment for reported_content_cell
    def current_organization
      @organization
    end

    def current_user
      @user
    end

    private

    def reported_content_url
      @reported_content_url ||= @report.moderation.reportable.reported_content_url
    end

    def report_url
      @report_url ||= EngineRouter.admin_proxy(@participatory_space).moderation_report_url(host: @organization.host, moderation_id: @report.moderation.id, id: @report.id)
    end

    def manage_moderations_url
      @manage_moderations_url ||= EngineRouter.admin_proxy(@participatory_space).moderations_url(host: @organization.host)
    end

    def author_profile_url
      @author_profile_url ||= @author.is_a?(Decidim::UserBaseEntity) && !@author.deleted? ? decidim.profile_url(@author.nickname, host: @organization.host) : nil
    end

    def original_language(reportable)
      return reportable.content_original_language if reportable.respond_to?(:content_original_language)

      @organization.default_locale
    end

    # This is needed to be able to use a cell in an ActionMailer, which is not supported out of the box by cells-rails.
    # We are passing the current object as if it was a controller.
    # We also need to define a 'current_organization' method, which is expected by Decidim::ViewModel.
    # A similar approach is used in Decidim::NewsletterMailer
    def reported_content_cell
      @reported_content_cell ||= ::Decidim::ViewModel.cell(
        "decidim/reported_content",
        @reportable,
        context: {
          controller: self
        }
      )
    end
  end
end
