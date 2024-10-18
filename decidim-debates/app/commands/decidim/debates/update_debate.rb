# frozen_string_literal: true

module Decidim
  module Debates
    # A command with all the business logic when a user updates a debate.
    class UpdateDebate < Decidim::Commands::UpdateResource
      fetch_form_attributes :taxonomizations

      private

      def update_resource
        with_events(with_transaction: true) do
          super
        end
      end

      def event_arguments
        {
          resource:,
          extra: {
            event_author: form.current_user,
            locale:
          }
        }
      end

      def extra_params = { visibility: "public-only" }

      def attributes
        parsed_title = Decidim::ContentProcessor.parse_with_processor(:hashtag, form.title, current_organization: form.current_organization).rewrite
        parsed_description = Decidim::ContentProcessor.parse_with_processor(:hashtag, form.description, current_organization: form.current_organization).rewrite
        super.merge({
                      title: { I18n.locale => parsed_title },
                      description: { I18n.locale => parsed_description }
                    })
      end
    end
  end
end
