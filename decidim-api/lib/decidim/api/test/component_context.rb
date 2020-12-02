# frozen_string_literal: true

require "decidim/api/test/type_context"

shared_context "with a graphql decidim component" do
  include_context "with a graphql type"

  let(:schema) { Decidim::Api::Schema }

  let(:locale) { "en" }

  let(:component_fragment) { }


  let(:participatory_process_query) do
    %Q(
      participatoryProcess {
        components{
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
    %Q(
      query {
        #{participatory_process_query}
      }
      #{component_fragment}
    )
  end
end
