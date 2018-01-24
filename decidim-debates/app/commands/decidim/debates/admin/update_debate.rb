# frozen_string_literal: true
module Decidim
  module Debates
    module Admin
      # This command is executed when the user changes a Debate from the admin
      # panel.
      class UpdateDebate < Rectify::Command
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
          return broadcast(:invalid) if @form.invalid?

          update_debate
          broadcast(:ok)
        end

        private

        def update_debate
          @debate.update_attributes!(
            category: @form.category,
            title: @form.title,
            description: @form.description,
            instructions: @form.instructions,
            end_time: @form.end_time,
            start_time: @form.start_time
          )
        end
      end
    end
  end
end
