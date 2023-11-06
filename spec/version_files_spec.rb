# frozen_string_literal: true

require "fileutils"

describe "Version files sanity" do
  context "with app_templates" do
    let(:app_folder) { "decidim-generators/lib/decidim/generators/app_templates" }

    it ".ruby-version is up to date" do
      expect(FileUtils.identical?(".ruby-version", "#{app_folder}/.ruby-version")).to be(true)
    end

    it ".node-version is up to date" do
      expect(FileUtils.identical?(".node-version", "#{app_folder}/.node-version")).to be(true)
    end
  end

  context "with component_templates" do
    let(:app_folder) { "decidim-generators/lib/decidim/generators/component_templates" }

    it ".ruby-version is up to date" do
      expect(FileUtils.identical?(".ruby-version", "#{app_folder}/.ruby-version")).to be(true)
    end

    it ".node-version is up to date" do
      expect(FileUtils.identical?(".node-version", "#{app_folder}/.node-version")).to be(true)
    end
  end
end
