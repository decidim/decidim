# frozen-string_literal: true

module Decidim
  class ParticipatoryProcessStepActivatedEvent < Decidim::Events::SimpleEvent
    include Rails.application.routes.mounted_helpers

    i18n_attributes :participatory_space_title

    def resource_path
      @resource_path ||= decidim_participatory_processes.participatory_process_participatory_process_steps_path(participatory_space)
    end

    def resource_url
      @resource_url ||= decidim_participatory_processes
                        .participatory_process_participatory_process_steps_url(
                          resource.participatory_process,
                          host: resource.participatory_process.organization.host
                        )
    end

    private

    def participatory_space_title
      participatory_space.title[I18n.locale.to_s]
    end

    def participatory_space
      resource.participatory_process
    end
  end
end
