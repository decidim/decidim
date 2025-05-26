# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      class UpdateElection < Decidim::Commands::UpdateResource
        include ::Decidim::GalleryMethods
        fetch_form_attributes :title, :description, :start_at, :end_at, :results_availability

        def initialize(form, election)
          super
          @attached_to = election
        end

        protected

        def attributes
          parsed_title = Decidim::ContentProcessor.parse_with_processor(:hashtag, form.title, current_organization: form.current_organization).rewrite
          parsed_description = Decidim::ContentProcessor.parse_with_processor(:hashtag, form.description, current_organization: form.current_organization).rewrite

          super.merge({
                        title: parsed_title,
                        description: parsed_description,
                        start_at: form.manual_start ? nil : form.start_at,
                        end_at: form.end_at,
                        results_availability: form.results_availability
                      })
        end

        def run_after_hooks
          create_gallery if process_gallery?
          photo_cleanup!
        end

        def run_before_hooks
          return unless process_gallery?

          build_gallery
          raise Decidim::Commands::HookError if gallery_invalid?
        end
      end
    end
  end
end
