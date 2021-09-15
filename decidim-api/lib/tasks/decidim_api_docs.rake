# frozen_string_literal: true

require "graphql-docs"

namespace :decidim_api do
  desc "Generates the API docs files"
  task generate_docs: :environment do
    output_dir = Rails.application.root.join("public", "static", "api", "docs")
    FileUtils.rm_rf(output_dir)

    GraphQLDocs.build(
      schema: Decidim::Api::Schema,
      output_dir: output_dir,
      base_url: "/api/docs",
      landing_pages: {
        index: File.expand_path("../../docs/usage.md", __dir__)
      },
      templates: {
        default: File.expand_path("../../app/views/decidim/api/documentation/graphql_docs_template.html.erb", __dir__)
      }
    )
  end
end
