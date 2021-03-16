# frozen_string_literal: true

module Decidim
  module Votings
    module Census
      module Admin
        # A command with the business logic to create census dataset for a
        # voting space.
        class CreateDataset < Rectify::Command
          def initialize(form, current_user)
            @form = form
            @current_user = current_user
          end

          # Executes the command. Broadcast this events:
          # - :ok when everything is valid
          # - :invalid when the form wasn't valid and couldn't proceed-
          #
          # Returns nothing.
          def call
            return broadcast(:invalid) unless form.valid?

            dataset = create_census_dataset!

            if dataset
              Decidim::Votings::Census::Admin::ProcessDatasetJob.perform_later(
                current_user,
                dataset,
                dataset.file.path
              )
            end

            broadcast(:ok)
          end

          attr_reader :form, :current_user

          def create_census_dataset!
            Decidim.traceability.create(
              Decidim::Votings::Census::Dataset,
              current_user,
              organization: form.current_participatory_space.organization,
              voting: form.current_participatory_space,
              file: form.file,
              status: :review_data
            )
          end
        end
      end
    end
  end
end
