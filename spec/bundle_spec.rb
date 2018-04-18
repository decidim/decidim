# frozen_string_literal: true

require "digest"

describe "Bundle sanity" do
  it "is up to date" do
    Dir.chdir("decidim_app-design") do
      previous_content = File.read("Gemfile.lock")

      new_content = Bundler.with_original_env do
        `BUNDLE_GEMFILE=./Gemfile bundle lock --print`
      end

      msg = "Please update the design_app lock file with `bundle install` from the `decidim_app-design folder"

      expect(new_content).to eq(previous_content), msg
    end
  end
end
