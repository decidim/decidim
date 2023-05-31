# frozen_string_literal: true

require "graphql-docs"

namespace :decidim_api do
  desc "Generates the API docs files"
  task generate_docs: :environment do
    output_dir = clear_previous_docs

    GraphQLDocs.build(
      schema: Decidim::Api::Schema,
      output_dir:,
      base_url: "/api/docs",
      landing_pages: {
        index: File.expand_path("../../docs/usage.md", __dir__)
      },
      templates: {
        default: File.expand_path("../../app/views/decidim/api/documentation/graphql_docs_template.html.erb", __dir__)
      }
    )

    clear_cache_folder
  end

  def clear_previous_docs
    output_dir = Rails.application.root.join("app", "views", "static", "api", "docs")
    FileUtils.rm_rf(output_dir)
    output_dir
  end

  def clear_cache_folder
    FileUtils.rm_rf(Rails.application.root.join(".sass-cache"))
  end
end
