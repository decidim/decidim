# frozen-string_literal: true

module Decidim
  class ReportCreatedEvent < Decidim::Events::SimpleEvent
    i18n_attributes :resource_path, :report_reason, :resource_type

    def resource_path
      @resource.reported_content_url
    end

    def resource_url
      @resource.reported_content_url
    end

    def report_reason
      I18n.t("decidim.admin.moderations.report.reasons.#{extra["report_reason"]}").downcase
    end

    def resource_type
      @resource.model_name.human.downcase
    end
  end
end
