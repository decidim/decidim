# frozen_string_literal: true

describe "Application generation" do
  let(:status) { system(command, out: File::NULL) }

  let(:test_app) { "spec/generator_test_app" }

  after { FileUtils.rm_rf(test_app) }

  shared_examples_for "a sane generator" do
    it "successfully generates application" do
      expect(status).to eq(true)
    end
  end

  context "with --edge flag" do
    let(:command) { "bin/decidim --edge #{test_app}" }

    it_behaves_like "a sane generator"
  end

  context "with --branch flag" do
    let(:command) { "bin/decidim --branch master #{test_app}" }

    it_behaves_like "a sane generator"
  end

  context "with --path flag" do
    let(:command) { "bin/decidim --path #{File.expand_path("..", __dir__)} #{test_app}" }

    it_behaves_like "a sane generator"
  end

  context "development application" do
    let(:command) { "rake development_app" }

    it_behaves_like "a sane generator"
  end
end
