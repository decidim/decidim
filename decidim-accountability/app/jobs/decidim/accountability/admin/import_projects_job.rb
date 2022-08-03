# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      class ImportProjectsJob < ApplicationJob
        queue_as :default
        def initialize(form)
          @form = form
        end

        def results_from_projects!(projects)
          projects.map do |original_project|
            next if form.project_already_copied?(original_project)

            new_result = create_result_from_project!(original_project, statuses.first)

            new_result.link_resources([original_project], "included_projects")
            new_result.link_resources(
              original_project.linked_resources(:proposals, "included_proposals"),
              "included_proposals"
            )

            copy_attachments(original_project, new_result)
          end.compact
        end

        def notify_user!
          Decidim::Accountability::ImportProjectsMailer.import(form.current_user).deliver_now
        end

        private

        attr_reader :form

        def create_result_from_project!(project, status)
          params = {
            title: project.title,
            description: project.description,
            category: project.category,
            scope: project.scope || project.budget.scope,
            component: form.current_component,
            status:,
            progress: status&.progress || 0
          }
          @result = Decidim.traceability.create!(
            Result,
            form.current_user,
            params,
            visibility: "all"
          )
        end

        def copy_attachments(project, result)
          project.attachments.each do |attachment|
            new_attachment = Decidim::Attachment.new(
              {
                # Attached to needs to be always defined before the file is set
                attached_to: result
              }.merge(
                attachment.attributes.slice("content_type", "description", "file_size", "title", "weight")
              )
            )

            if attachment.file.attached?
              new_attachment.file = attachment.file.blob
            else
              new_attachment.attached_uploader(:file).remote_url = attachment.attached_uploader(:file).url(host: project.organization.host)
            end

            new_attachment.save!
          end
        end

        def statuses
          Decidim::Accountability::Status.where(component: form.current_component).order(:progress)
        end
      end
    end
  end
end
