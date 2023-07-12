# frozen_string_literal: true

require "spec_helper"

describe "rake decidim:webpacker:install", type: :task do
  it "preloads the Rails environment" do
    expect(task.prerequisites).to include "environment"
  end

  it "have changed the app's package.json file" do
    package_json = Rails.root.join("package.json")
    FileUtils.rm(package_json)

    task.execute

    package_json_content = JSON.parse(File.read(package_json))
    expect(package_json_content["dependencies"].keys).to contain_exactly("@decidim/browserslist-config", "@decidim/core", "@decidim/elections", "@decidim/webpacker")
    expect(package_json_content["devDependencies"].keys).to contain_exactly("@decidim/dev", "@decidim/eslint-config", "@decidim/prettier-config", "@decidim/stylelint-config")
  end
end
