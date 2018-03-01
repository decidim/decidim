# This migration comes from decidim_verifications (originally 20171030133426)
# frozen_string_literal: true

#
# Assumes to authorizations in the old format (as rectify form classes) will be
# registered as the underscored class name using the new API. For example, a
# previous
#
# ```
# config.authorization_handlers = ["Decidim::ExampleCensusHandler"]
# ```
#
# will now be
#
# ```
# Decidim::Verifications.register_workflow(:example_census_handler) do |auth|
#   auth.form = "Decidim::ExampleCensusHandler"
# end
# ```
#
class MoveAuthorizationsToNewApi < ActiveRecord::Migration[5.1]
  class Organization < ApplicationRecord
    self.table_name = :decidim_organizations
  end

  class Feature < ApplicationRecord
    self.table_name = :decidim_features
  end

  def up
    Organization.find_each do |organization|
      migrated_authorizations = organization.available_authorizations.map do |authorization|
        authorization.demodulize.underscore
      end

      organization.update!(available_authorizations: migrated_authorizations)
    end

    Feature.find_each do |feature|
      next if feature.permissions.nil?

      feature.permissions.transform_values! do |value|
        next if value.nil?

        {
          "authorization_handler_name" => value["authorization_handler_name"]&.classify&.demodulize&.underscore,
          "options" => value["options"]
        }
      end

      feature.save!
    end
  end

  def down
    Organization.find_each do |organization|
      migrated_authorizations = organization.available_authorizations.map do |authorization|
        Decidim::Verifications.find_workflow_manifest(authorization).form
      end

      organization.update!(available_authorizations: migrated_authorizations)
    end

    Feature.find_each do |feature|
      feature.permissions.transform_values! do |value|
        workflow = Decidim::Verifications.find_workflow_manifest(value)

        workflow.form.underscore
      end

      feature.save!
    end
  end
end
