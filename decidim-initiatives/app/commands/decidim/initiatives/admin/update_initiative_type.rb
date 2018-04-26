# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      # A command with all the business logic that updates an
      # existing initiative type.
      class UpdateInitiativeType < Rectify::Command
        # Public: Initializes the command.
        #
        # initiative_type: Decidim::InitiativesType
        # form - A form object with the params.
        def initialize(initiative_type, form)
          @form = form
          @initiative_type = initiative_type
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?
          initiative_type.update(attributes)

          if initiative_type.valid?
            broadcast(:ok, initiative_type)
          else
            broadcast(:invalid)
          end
        end

        private

        attr_reader :form, :initiative_type

        def attributes
          result = {
            title: form.title,
            description: form.description
          }

          result[:banner_image] = form.banner_image unless form.banner_image.nil?
          result
        end
      end
    end
  end
end
