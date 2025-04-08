# frozen_string_literal: true

module Decidim
  module Verifications
    module CsvCensus
      module Admin
        # A command with the business logic to create census data for a
        # organization.
        class CreateCensusRecord < Decidim::Commands::CreateResource
          fetch_form_attributes :email, :organization

          private

          def resource_class = Decidim::Verifications::CsvDatum

          def run_before_hooks
            @resource = resource_class.find_by(email: form.email, organization: form.organization)

            if @resource
              form.errors.add(:email, I18n.t("census.new_import.errors.email_exists", scope: "decidim.verifications.csv_census.admin"))
              return
            else
              @resource = resource_class.create!(email: form.email, organization: form.organization)
            end

            @resource.authorize!(current_user)
          end
        end
      end
    end
  end
end
