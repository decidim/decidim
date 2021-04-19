# frozen_string_literal: true

module Decidim
  module Debates
    # A command with all the business logic when a user updates a debate.
    class UpdateDebate < Rectify::Command
      # Public: Initializes the command.
      #
      # form         - A form object with the params.
      def initialize(form)
        @form = form
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the debate.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?
        return broadcast(:invalid) unless form.debate.editable_by?(form.current_user)

        update_debate
        broadcast(:ok, @debate)
      end

      private

      attr_reader :form

      def update_debate
        @debate = Decidim.traceability.update!(
          @form.debate,
          @form.current_user,
          attributes,
          visibility: "public-only"
        )
      end

      def attributes
        parsed_title = Decidim::ContentProcessor.parse_with_processor(:hashtag, form.title, current_organization: form.current_organization).rewrite
        parsed_description = Decidim::ContentProcessor.parse_with_processor(:hashtag, form.description, current_organization: form.current_organization).rewrite
        {
          category: form.category,
          title: {
            I18n.locale => parsed_title
          },
          description: {
            I18n.locale => parsed_description
          },
          scope: form.scope
        }
      end
    end
  end
end
