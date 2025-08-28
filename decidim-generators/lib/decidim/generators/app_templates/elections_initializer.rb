# frozen_string_literal: true

# This is just an example on how to register a custom census in the elections module.
# Decidim::Elections.census_registry.register(:my_census) do |manifest|
#   manifest.admin_form = "MyApp::MyCensusForm"
#   manifest.admin_form_partial = "my_app/my_census_form"
#   # This query should return users that will be part of the census.
#   manifest.user_query do |election|
#     election.organization.users.where(extended_data: { my_census_field: true })
#   end
# end
