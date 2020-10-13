# frozen-string_literal: true

module Decidim
  class ReportCreatedEvent < Decidim::Events::SimpleEvent
    delegate :url_helpers, to: "Decidim::Core::Engine.routes"

    i18n_attributes :resource_path, :report_reason, :resource_title

    def resource_path
      # TODO: use url_helpers to get the path to the reported resource
      "/reported_resource"
    end

    def resource_url
      # TODO: use url_helpers to get the url to the reported resource
      "localhost:3000/reported_resource"
    end

    def resource_title
      # TODO: figure out what to use as resource title
      "miao"
    end

    def report_reason
      @resource.reason
    end
  end
end
