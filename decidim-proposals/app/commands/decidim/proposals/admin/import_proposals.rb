# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A command with all the business logic when an admin imports proposals from
      # one component to another.
      class ImportProposals < Decidim::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form)
          @form = form
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form was not valid and we could not proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless form.valid?

          import_proposals
          broadcast(:ok)
        end

        private

        attr_reader :form

        def import_proposals
          ImportProposalsJob.perform_later(form.as_json.merge({
                                                                "current_user_id" => form.current_user.id,
                                                                "current_organization_id" => form.current_organization.id,
                                                                "current_component_id" => form.current_component.id
                                                              }))
        end
      end
    end
  end
end
