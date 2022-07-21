# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # A command with all the business logic when an admin imports projects from
      # one component to accountability.
      class ImportProjectsToAccountability < Decidim::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form)
          @form = form
        end

        def call
          return broadcast(:invalid) unless form.valid?

          broadcast(:ok, results_from_projects)
        end

        private

        attr_reader :form

        def results_from_projects
          transaction do
            projects.map do |original_project|
              next if project_already_copied?(original_project)

              new_result = create_result_from_project!(original_project, statuses.first)

              new_result.link_resources([original_project], "included_projects")
              new_result.link_resources(
                original_project.linked_resources(:proposals, "included_proposals"),
                "included_proposals"
              )

              copy_attachments(original_project, new_result)
            end.compact
          end
        end

        def origin_component
          form.origin_component
        end

        def create_result_from_project!(project, status)
          params = {
            title: project.title,
            description: project.description,
            category: project.category,
            scope: project.scope || project.budget.scope,
            component: form.current_component,
            status: status,
            progress: status&.progress || 0
          }
          @result = Decidim.traceability.create!(
            Result,
            form.current_user,
            params,
            visibility: "all"
          )
        end

        def project_already_copied?(original_project)
          original_project.linked_resources(:results, "included_projects").any? do |result|
            result.component == current_component
          end
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

        def projects
          Decidim::Budgets::Project.joins(:budget).selected.where(
            budget: { component: origin_component }
          )
        end

        # Needs to be removed after tests
        def budgets
          Budget.where(component: current_component).order(weight: :asc)
        end
      end
    end
  end
end
