# frozen_string_literal: true

module Decidim
  module Debates
    module Admin
      # This command is executed when the user changes a Debate from the admin
      # panel.
      class UpdateDebate < Decidim::Command
        # Initializes a UpdateDebate Command.
        #
        # form - The form from which to get the data.
        # debate - The current instance of the page to be updated.
        def initialize(form, debate)
          @form = form
          @debate = debate
        end

        # Updates the debate if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          update_debate
          broadcast(:ok)
        end

        private

        attr_reader :debate, :form

        def update_debate
          parsed_title = Decidim::ContentProcessor.parse_with_processor(:hashtag, form.title, current_organization: form.current_organization).rewrite
          parsed_description = Decidim::ContentProcessor.parse_with_processor(:hashtag, form.description, current_organization: form.current_organization).rewrite

          Decidim.traceability.update!(
            debate,
            form.current_user,
            category: form.category,
            title: parsed_title,
            description: parsed_description,
            information_updates: form.information_updates,
            instructions: form.instructions,
            end_time: form.end_time,
            start_time: form.start_time,
            scope: form.scope,
            comments_enabled: form.comments_enabled
          )
        end
      end
    end
  end
end
