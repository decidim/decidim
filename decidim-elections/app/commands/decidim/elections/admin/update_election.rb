# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      class UpdateElection < Decidim::Commands::UpdateResource
        include ::Decidim::MultipleAttachmentsMethods

        fetch_form_attributes :title, :description, :start_at, :end_at, :results_availability

        def initialize(form, election)
          super
          @attached_to = election
        end

        private

        alias election resource

        def attributes
          election.started? ? started_election_attributes : not_started_election_attributes
        end

        def started_election_attributes
          { description: parsed_description }
        end

        def not_started_election_attributes
          {
            title: parsed_title,
            description: parsed_description,
            start_at: form.manual_start ? nil : form.start_at,
            end_at: form.end_at,
            results_availability: form.results_availability
          }
        end

        def parsed_title
          Decidim::ContentProcessor.parse(form.title, current_organization: form.current_organization).rewrite
        end

        def parsed_description
          Decidim::ContentProcessor.parse(form.description, current_organization: form.current_organization).rewrite
        end

        def run_after_hooks
          create_attachments if process_attachments?
          attachment_cleanup!(include_all_attachments: true)
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
