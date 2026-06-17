# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      class CreateElection < Decidim::Commands::CreateResource
        include ::Decidim::MultipleAttachmentsMethods

        fetch_form_attributes :title, :description, :start_at, :end_at, :results_availability

        protected

        attr_reader :attachments

        def resource_class = Decidim::Elections::Election

        def extra_params
          { visibility: "all" }
        end

        def attributes
          parsed_title = Decidim::ContentProcessor.parse(form.title, current_organization: form.current_organization).rewrite
          parsed_description = Decidim::ContentProcessor.parse_with_processor(:inline_images, form.description, current_organization: form.current_organization).rewrite

          super.merge({
                        component: form.current_component,
                        title: parsed_title,
                        description: parsed_description,
                        start_at: form.manual_start ? nil : form.start_at,
                        end_at: form.end_at,
                        results_availability: form.results_availability
                      })
        end

        def run_after_hooks
          @attached_to = resource
          create_attachments if process_attachments?
        end

        def run_before_hooks
          return unless process_attachments?

          build_attachments
          raise Decidim::Commands::HookError if attachments_invalid?
        end
      end
    end
  end
end
