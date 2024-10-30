# frozen_string_literal: true

require "decidim/api/test/type_context"

shared_context "with a graphql decidim component" do
  include_context "with a graphql class type"

  let(:schema) { Decidim::Api::Schema }

  let(:locale) { "en" }

  let(:participatory_process) { create(:participatory_process, organization: current_organization) }
  let(:taxonomy) { create(:taxonomy, :with_parent, organization: participatory_process.organization) }
  let(:taxonomies) { [taxonomy] }

  let(:component_type) { nil }
  let(:component_fragment) { nil }

  let(:participatory_process_query) do
    %(
      participatoryProcess(id: #{participatory_process.id}) {
        components(filter: {type: "#{component_type}"}){
          id
          name {
            translation(locale: "#{locale}")
          }
          weight
          __typename
          ...fooComponent
        }
        id
      }
    )
  end

  let(:query) do
    %(
      query {
        #{participatory_process_query}
      }
      #{component_fragment}
    )
  end
end
