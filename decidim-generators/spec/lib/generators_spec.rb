# frozen_string_literal: true

require "simplecov" if ENV["SIMPLECOV"]

require "decidim/generators"

module Decidim
  describe Generators do
    describe ".edge_git_branch" do
      let(:test_version) { nil }

      before do
        allow(described_class).to receive(:version).and_return(test_version)
      end

      context "with dev version" do
        let(:test_version) { "0.27.0.dev" }

        it "returns the develop branch" do
          expect(subject.edge_git_branch).to eq("feature/demographics")
        end
      end

      context "with pre version" do
        let(:test_version) { "0.27.0.pre1" }

        it "returns the release branch" do
          expect(subject.edge_git_branch).to eq("release/0.27-stable")
        end
      end

      context "with alpha version" do
        let(:test_version) { "0.27.0.alpha9" }

        it "returns the release branch" do
          expect(subject.edge_git_branch).to eq("release/0.27-stable")
        end
      end

      context "with beta version" do
        let(:test_version) { "0.27.0.beta2" }

        it "returns the release branch" do
          expect(subject.edge_git_branch).to eq("release/0.27-stable")
        end
      end

      context "with release candidate version" do
        let(:test_version) { "0.27.0.rc4" }

        it "returns the release branch" do
          expect(subject.edge_git_branch).to eq("release/0.27-stable")
        end
      end

      context "with release version" do
        let(:test_version) { "0.27.99" }

        it "returns the release branch" do
          expect(subject.edge_git_branch).to eq("release/0.27-stable")
        end
      end
    end
  end
end
