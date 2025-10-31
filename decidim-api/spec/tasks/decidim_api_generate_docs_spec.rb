# frozen_string_literal: true

require "spec_helper"

describe "rake decidim_api:generate_docs", type: :task do
  it "creates the static docs files" do
    static = Rails.root.join("app/views/static/api/docs")

    # We do not actually remove the files and execute this command, as this generates
    # flaky specs with other tasks that are  checking out the documentation.
    #
    # This task is already executed during the test dummy app generation so there is
    # not need to check after removing the files.
    #
    # FileUtils.rm_rf(static)
    # task.execute

    index = File.read("#{static}/index.html")
    expect(index).to include("About the GraphQL API")
    expect(index).to include("GraphQL Reference")
  end
end
