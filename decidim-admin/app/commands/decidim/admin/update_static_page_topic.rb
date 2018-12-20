# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic when updating a static page topic.
    class UpdateStaticPageTopic < Rectify::Command
      # Public: Initializes the command.
      #
      # page - The StaticPageTopic to update
      # form - A form object with the params.
      def initialize(topic, form)
        @topic = topic
        @form = form
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        update_topic
        broadcast(:ok)
      end

      private

      attr_reader :form

      def update_topic
        Decidim.traceability.update!(
          @topic,
          form.current_user,
          attributes
        )
      end

      def attributes
        {
          title: form.title,
          description: form.description,
          show_in_footer: form.show_in_footer,
          weight: form.weight
        }
      end
    end
  end
end
