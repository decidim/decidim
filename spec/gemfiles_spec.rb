# frozen_string_literal: true

require "digest"

describe "Gemfile sanity" do
  shared_examples_for "a folder with a secondary gemfile" do |folder|
    it "is up to date" do
      Dir.chdir(folder) do
        previous_content = File.read("Gemfile.lock")

        new_content = Bundler.with_original_env do
          `BUNDLE_GEMFILE=./Gemfile bundle lock --print`
        end

        msg = "Please update the #{folder}'s lock file with `bundle install` from inside it"

        expect(new_content).to eq(previous_content), msg
      end
    end
  end

  it_behaves_like "a folder with a secondary gemfile", "decidim_app-design"
  it_behaves_like "a folder with a secondary gemfile", "decidim-generators"
end
