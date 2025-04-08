# frozen_string_literal: true

module Decidim
  module Verifications
    module CsvCensus
      module Admin
        # A command with the business logic to create census data for a
        # organization.
        class CreateCensusRecord < Decidim::Commands::CreateResource
          fetch_form_attributes :email, :organization

          def call
            return broadcast(:invalid) if invalid?

            if resource_class.exists?(email: form.email, organization: form.organization)
              broadcast(:invalid,
                        error: I18n.t("census.new_import.errors.email_exists", scope: "decidim.verifications.csv_census.admin", email: form.email,
                                                                               organization: form.organization.id))
            end

            create_resource

            broadcast(:ok, resource)
          end

          private

          def resource_class = Decidim::Verifications::CsvDatum

          def run_after_hooks
            @resource.authorize!
          end
        end
      end
    end
  end
end
