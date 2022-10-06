# frozen_string_literal: true

require "digest"
require "fileutils"

describe "Webpacker sanity" do
  shared_examples_for "a folder with a secondary Webpacker configuration" do |folder|
    it "package.json is up to date" do
      expect(FileUtils.identical?("package.json", "#{folder}/package.json")).to be(true)
    end

    it "package-lock.json is up to date" do
      expect(FileUtils.identical?("package-lock.json", "#{folder}/package-lock.json")).to be(true)
    end
  end

  it_behaves_like "a folder with a secondary Webpacker configuration", "decidim_app-design"
end
