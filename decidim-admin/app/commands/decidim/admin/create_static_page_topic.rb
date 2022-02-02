# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic when creating a static page topic.
    class CreateStaticPageTopic < Decidim::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      def initialize(form)
        @form = form
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if @form.invalid?

        @topic = Decidim.traceability.create!(
          StaticPageTopic,
          @form.current_user,
          title: @form.title,
          description: @form.description,
          organization: @form.current_organization,
          show_in_footer: @form.show_in_footer,
          weight: @form.weight
        )
        broadcast(:ok)
      end
    end
  end
end
