# frozen_string_literal: true

module Decidim
  module Debates
    # This command is executed when the user creates a Debate from the public
    # views.
    class CreateDebate < Rectify::Command
      def initialize(form)
        @form = form
      end

      # Creates the debate if valid.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        return broadcast(:invalid) if form.invalid?

        create_debate
        broadcast(:ok, debate)
      end

      private

      attr_reader :debate, :form

      def organization
        @organization = form.current_feature.organization
      end

      def i18n_field(field)
        organization.available_locales.inject({}) do |i18n, locale|
          i18n.update(locale => field)
        end
      end

      def create_debate
        @debate = Debate.create!(
          author: form.current_user,
          decidim_user_group_id: form.user_group_id,
          category: form.category,
          title: i18n_field(form.title),
          description: i18n_field(form.description),
          instructions: i18n_field(form.instructions),
          feature: form.current_feature
        )
      end
    end
  end
end
