# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      # A command with all the business logic that creates a new initiative type scope
      class CreateInitiativeTypeScope < Decidim::Command
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
          return broadcast(:invalid) if form.invalid?

          initiative_type_scope = create_initiative_type_scope

          if initiative_type_scope.persisted?
            broadcast(:ok, initiative_type_scope)
          else
            initiative_type_scope.errors.each do |error|
              form.errors.add(error.attribute, error.message)
            end

            broadcast(:invalid)
          end
        end

        private

        attr_reader :form

        def create_initiative_type_scope
          initiative_type = InitiativesTypeScope.new(
            supports_required: form.supports_required,
            decidim_scopes_id: form.decidim_scopes_id,
            decidim_initiatives_types_id: form.context.type_id
          )

          return initiative_type unless initiative_type.valid?

          initiative_type.save
          initiative_type
        end
      end
    end
  end
end
