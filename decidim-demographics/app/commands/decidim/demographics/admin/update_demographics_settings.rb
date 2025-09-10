# frozen_string_literal: true

module Decidim
  module Demographics
    module Admin
      class UpdateDemographicsSettings < Decidim::Command
        # Initializes an UpdateDemographicsSettings Command.
        #
        # @param form - The form from which to get the data.
        def initialize(form)
          @form = form
        end

        attr_reader :form

        delegate :current_organization, to: :form
        delegate :current_user, to: :form

        # Updates the demographic data if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          Decidim.traceability.perform_action!("update", demographic, current_user) do
            update_demographic_settings
          end

          broadcast(:ok)
        rescue ActiveRecord::RecordInvalid
          broadcast(:invalid)
        end

        private

        def demographic
          @demographic ||= Decidim::Demographics::Demographic.where(organization: current_organization).first_or_create!
        end

        def update_demographic_settings
          demographic.update!(collect_data: form.collect_data)
        end
      end
    end
  end
end
