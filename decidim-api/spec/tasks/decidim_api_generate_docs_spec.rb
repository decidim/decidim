# frozen_string_literal: true

require "spec_helper"

describe "rake decidim_api:generate_docs", type: :task do
  it "creates the static docs files" do
    static = Rails.root.join("app/views/static/api/docs")
    FileUtils.rm_rf(static)

    task.execute

    index = File.read("#{static}/index.html")
    expect(index).to include("About the GraphQL API")
    expect(index).to include("GraphQL Reference")
  end
end
