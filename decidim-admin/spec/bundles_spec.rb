# frozen_string_literal: true

require "spec_helper"

describe "Bundles sanity" do
  shared_examples "a valid bundle" do
    it "is up to date" do
      previous_hash = bundle_hash

      Dir.chdir("../") do
        expect(system(command, out: File::NULL, err: File::NULL)).to eq(true)
      end

      new_hash = bundle_hash

      expect(previous_hash).to eq(new_hash),
                               "Please normalize the admin bundles with `#{command}` from the Decidim root folder"
    end
  end

  let(:command) { "npm run build:prod" }

  describe "javascript bundle" do
    let(:bundle_path) { "app/assets/javascripts/decidim/admin/bundle.js" }

    it_behaves_like "a valid bundle"
  end

  describe "styles bundle" do
    let(:bundle_path) { "app/assets/stylesheets/decidim/admin/bundle.scss" }

    it_behaves_like "a valid bundle"
  end

  def bundle_hash
    Digest::MD5.file(bundle_path).hexdigest
  end
end
