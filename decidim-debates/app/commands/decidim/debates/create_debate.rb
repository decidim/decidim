# frozen_string_literal: true

module Decidim
  module Debates
    # This command is executed when the user creates a Debate from the public
    # views.
    class CreateDebate < Decidim::Command
      def initialize(form)
        @form = form
      end

      # Creates the debate if valid.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        return broadcast(:invalid) if form.invalid?

        with_events(with_transaction: true, before: false) do
          create_debate
        end
        broadcast(:ok, debate)
      end

      private

      attr_reader :debate, :form

      def event_arguments
        {
          resource: debate,
          extra: {
            event_author: form.current_user,
            locale:
          }
        }
      end

      def create_debate
        parsed_title = Decidim::ContentProcessor.parse_with_processor(:hashtag, form.title, current_organization: form.current_organization).rewrite
        parsed_description = Decidim::ContentProcessor.parse_with_processor(:hashtag, form.description, current_organization: form.current_organization).rewrite
        params = {
          author: form.current_user,
          decidim_user_group_id: form.user_group_id,
          category: form.category,
          title: {
            I18n.locale => parsed_title
          },
          description: {
            I18n.locale => parsed_description
          },
          scope: form.scope,
          component: form.current_component
        }

        @debate = Decidim.traceability.create!(
          Debate,
          form.current_user,
          params,
          visibility: "public-only"
        )
      end
    end
  end
end
