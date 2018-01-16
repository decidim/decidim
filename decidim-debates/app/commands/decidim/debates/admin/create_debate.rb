# frozen_string_literal: true
module Decidim
  module Debates
    module Admin
      # This command is executed when the user creates a Debate from the admin
      # panel.
      class CreateDebate < Rectify::Command
        def initialize(form)
          @form = form
        end

        # Creates the debate if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if @form.invalid?

          create_debate
          broadcast(:ok)
        end

        private

        def create_debate
          Debate.create!(
            category: @form.category,
            title: @form.title,
            description: @form.description,
            instructions: @form.instructions,
            end_time: @form.end_time,
            start_time: @form.start_time,
            feature: @form.current_feature
          )
        end
      end
    end
  end
end
