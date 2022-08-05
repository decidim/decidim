# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      class ImportProjectsJob < ApplicationJob
        queue_as :default

        def perform(projects, current_component, current_user)
          projects.map do |id|
            original_project = Decidim::Budgets::Project.find_by(id:)

            new_result = create_result_from_project!(original_project, statuses(current_component).first, current_component, current_user)
            new_result.link_resources([original_project], "included_projects")
            new_result.link_resources(
              original_project.linked_resources(:proposals, "included_proposals"),
              "included_proposals"
            )

            copy_attachments(original_project, new_result)
          end.compact
          Decidim::Accountability::ImportProjectsMailer.import(current_user).deliver_now
        end

        private

        def create_result_from_project!(project, status, component, user)
          params = {
            title: project.title,
            description: project.description,
            category: project.category,
            scope: project.scope || project.budget.scope,
            component:,
            status:,
            progress: status&.progress || 0
          }
          @result = Decidim.traceability.create!(
            Result,
            user,
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
              new_attachment.attached_uploader(:file).remote_url = attachment.attached_uploader(:file)
            end

            new_attachment.save!
          end
        end

        def statuses(current_component)
          Decidim::Accountability::Status.where(component: current_component).order(:progress)
        end
      end
    end
  end
end
