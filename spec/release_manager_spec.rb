# frozen_string_literal: true

require "decidim/release_manager"

describe "Decidim::ReleaseManager" do
  subject(:release_manager) { Decidim::ReleaseManager }

  describe ".npm_tag" do
    around do |example|
      original_npm_tag = ENV.fetch("NPM_TAG", nil)
      ENV.delete("NPM_TAG")
      example.run
    ensure
      original_npm_tag.nil? ? ENV.delete("NPM_TAG") : ENV["NPM_TAG"] = original_npm_tag
    end

    it "returns next for prerelease versions" do
      expect(release_manager.npm_tag("0.33.0.rc1")).to eq("next")
    end

    it "returns latest for stable versions" do
      expect(release_manager.npm_tag("0.32.3")).to eq("latest")
    end

    context "when NPM_TAG is set" do
      before do
        ENV["NPM_TAG"] = "release-0.31"
      end

      it "overrides the inferred tag" do
        expect(release_manager.npm_tag("0.33.0.rc1")).to eq("release-0.31")
      end
    end
  end
end
