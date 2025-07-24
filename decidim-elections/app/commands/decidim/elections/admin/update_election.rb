# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      class UpdateElection < Decidim::Commands::UpdateResource
        include ::Decidim::GalleryMethods
        fetch_form_attributes :title, :description, :start_at, :end_at, :results_availability

        def initialize(form, election)
          super
          @attached_to = election unless election.published?
        end

        private

        alias election resource

        def attributes
          election.published? ? published_election_attributes : unpublished_election_attributes
        end

        def published_election_attributes
          { description: parsed_description }
        end

        def unpublished_election_attributes
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
          return if election.published?

          create_gallery if process_gallery?
          photo_cleanup!
        end

        def run_before_hooks
          return if election.published?
          return unless process_gallery?

          build_gallery
          raise Decidim::Commands::HookError if gallery_invalid?
        end
      end
    end
  end
end
