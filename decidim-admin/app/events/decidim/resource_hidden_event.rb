# frozen_string_literal: true

module Decidim
  class ResourceHiddenEvent < Decidim::Events::SimpleEvent
    include Decidim::ApplicationHelper

    i18n_attributes :resource_path, :report_reasons, :resource_type, :resource_content

    def self.types
      [:email]
    end

    def resource_path
      @resource.reported_content_url
    end

    def resource_url
      @resource.reported_content_url
    end

    def report_reasons
      extra["report_reasons"].map do |reason|
        I18n.t("decidim.admin.moderations.report.reasons.#{reason}").downcase
      end.join(", ")
    end

    def resource_title
      nil
    end

    def resource_content
      text = translated_attribute(@resource[@resource.reported_attributes.first])

      decidim_sanitize(html_truncate(text, length: 100), strip_tags: true)
    end

    def resource_text
      "<i>#{resource_content}</i>"
    end

    def resource_type
      @resource.model_name.human.downcase
    end
  end
end
