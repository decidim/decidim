# frozen_string_literal: true

require "decidim/release_manager"

describe "Decidim::ReleaseManager" do
  subject(:release_manager) { Decidim::ReleaseManager }

  let(:latest_stable_version) { "0.32.3" }
  let(:versions) do
    [
      { "number" => "0.33.0.rc1", "prerelease" => true },
      { "number" => latest_stable_version, "prerelease" => false },
      { "number" => "0.32.2", "prerelease" => false },
      { "number" => "0.31.9", "prerelease" => false }
    ]
  end

  before do
    allow(Net::HTTP).to receive(:get).with(URI(release_manager::RUBYGEMS_VERSIONS_URL)).and_return(versions.to_json)
  end

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

    it "returns latest for the latest stable version" do
      expect(release_manager.npm_tag(latest_stable_version)).to eq("latest")
    end

    it "returns latest for a stable version newer than the latest stable version" do
      expect(release_manager.npm_tag("0.33.0")).to eq("latest")
    end

    it "returns the maintenance tag for an older stable version" do
      expect(release_manager.npm_tag("0.31.9")).to eq("release-0.31")
    end

    it "uses the current Decidim version by default" do
      allow(Decidim::GemManager).to receive(:version).and_return("0.31.9")

      expect(release_manager.npm_tag).to eq("release-0.31")
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

  describe ".latest_stable_version" do
    it "returns the latest stable version from RubyGems" do
      expect(release_manager.latest_stable_version).to eq(Gem::Version.new(latest_stable_version))
    end
  end
end
