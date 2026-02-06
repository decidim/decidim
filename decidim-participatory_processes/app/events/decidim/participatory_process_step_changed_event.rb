# frozen_string_literal: true

module Decidim
  class ParticipatoryProcessStepChangedEvent < Decidim::Events::SimpleEvent
    include Rails.application.routes.mounted_helpers

    def resource_path
      @resource_path ||= decidim_participatory_processes.participatory_process_path(participatory_space, locale: I18n.locale, display_steps: true)
    end

    def resource_url
      @resource_url ||= decidim_participatory_processes
                        .participatory_process_url(
                          participatory_space,
                          locale: I18n.locale,
                          display_steps: true,
                          host: participatory_space.organization.host
                        )
    end

    def participatory_space
      resource.participatory_process
    end
  end
end
