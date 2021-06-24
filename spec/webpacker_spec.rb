# frozen_string_literal: true

require "diffy"
require "digest"
require "json"

describe "Webpacker sanity" do
  shared_examples_for "a folder with a secondary Webpacker configuration" do |folder|
    let(:version) { Decidim.version.sub(/\.dev$/, "-dev") }

    it "package.json is up to date" do
      main = File.read("package.json")
      target = File.read("#{folder}/package.json")
      diff = Diffy::Diff.new(main, target, context: 0).to_s

      expect(diff).to eq(
        <<~DIFF
          -    "@decidim/all": "file:packages/all"
          +    "@decidim/all": "file:tmp/npmbuild/decidim-all-#{version}.tgz",
          +    "decidim-local-installer": "github:decidim/decidim-npm-local"
          -    "@decidim/dev": "file:packages/dev",
          +    "@decidim/dev": "file:tmp/npmbuild/decidim-dev-#{version}.tgz",
        DIFF
      )
    end

    it "package-lock.json is up to date" do
      main = JSON.parse(File.read("package-lock.json"))
      target = JSON.parse(File.read("#{folder}/package-lock.json"))

      main_packages = main["packages"][""]
      target_packages = target["packages"][""]

      main_prod = JSON.pretty_generate(main_packages["dependencies"])
      target_prod = JSON.pretty_generate(target_packages["dependencies"])
      diff_prod = Diffy::Diff.new(main_prod, target_prod, context: 0).to_s
      expect(diff_prod).to eq(
        <<~DIFF
          -  "@decidim/all": "file:packages/all"
          +  "@decidim/all": "file:tmp/npmbuild/decidim-all-#{version}.tgz",
          +  "decidim-local-installer": "github:decidim/decidim-npm-local"
        DIFF
      )

      main_dev = JSON.pretty_generate(main_packages["devDependencies"])
      target_dev = JSON.pretty_generate(target_packages["devDependencies"])
      diff_dev = Diffy::Diff.new(main_dev, target_dev, context: 0).to_s
      expect(diff_dev).to eq(
        <<~DIFF
          -  "@decidim/dev": "file:packages/dev",
          +  "@decidim/dev": "file:tmp/npmbuild/decidim-dev-#{version}.tgz",
        DIFF
      )
    end
  end

  it_behaves_like "a folder with a secondary Webpacker configuration", "decidim_app-design"
end
