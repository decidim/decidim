# frozen_string_literal: true

module Decidim
  module Templates
    module Admin
      # Updates the questionnaire template given form data.
      class UpdateTemplate < Decidim::Command
        # Initializes the command.
        #
        # template - The Template to update.
        # form        - The form object containing the data to update.
        # user        - The user that updates the template.
        def initialize(template, form, user)
          @template = template
          @form = form
          @user = user
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless @form.valid?
          return broadcast(:invalid) unless @user.organization == @template.organization

          @template = Decidim.traceability.update!(
            @template,
            @user,
            name: @form.name,
            description: @form.description
          )

          broadcast(:ok, @template)
        end
      end
    end
  end
end
