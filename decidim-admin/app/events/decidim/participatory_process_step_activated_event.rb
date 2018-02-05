# frozen-string_literal: true

module Decidim
  class ParticipatoryProcessStepActivatedEvent < Decidim::Events::SimpleEvent
    include Rails.application.routes.mounted_helpers

    def resource_path
      @resource_path ||= decidim_participatory_processes.participatory_process_participatory_process_steps_path(participatory_space)
    end

    def resource_url
      @resource_url ||= decidim_participatory_processes
                        .participatory_process_participatory_process_steps_url(
                          participatory_space,
                          host: participatory_space.organization.host
                        )
    end
  end
end
