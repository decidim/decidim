# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      class UpdateElection < Decidim::Commands::UpdateResource
        fetch_form_attributes :component, :title, :description, :start_at, :end_at, :results_availability

        protected

        def attributes
          parsed_title = Decidim::ContentProcessor.parse_with_processor(:hashtag, form.title, current_organization: form.current_organization).rewrite
          parsed_description = Decidim::ContentProcessor.parse_with_processor(:hashtag, form.description, current_organization: form.current_organization).rewrite

          super.merge({
                        title: parsed_title,
                        description: parsed_description,
                        start_at: form.manual_start ? nil : form.start_at,
                        end_at: form.manual_start ? nil : form.end_at,
                        results_availability: form.results_availability
                      })
        end
      end
    end
  end
end
