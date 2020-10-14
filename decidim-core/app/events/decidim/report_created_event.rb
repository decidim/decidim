# frozen-string_literal: true

module Decidim
  class ReportCreatedEvent < Decidim::Events::SimpleEvent
    delegate :url_helpers, to: "Decidim::Core::Engine.routes"

    i18n_attributes :resource_path, :report_reason, :resource_type

    def resource_path
      @resource.moderation.reportable.reported_content_url
    end

    def resource_url
      @resource.moderation.reportable.reported_content_url
    end

    def resource_title
      @resource.moderation.reportable.try(:title) || resource_type
    end

    def report_reason
      I18n.t("decidim.admin.moderations.report.reasons.#{@resource.reason}").downcase
    end

    def resource_type
      @resource.moderation.reportable.model_name.human.downcase
    end
  end
end
