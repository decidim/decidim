# frozen_string_literal: true

describe "Application generation" do
  let(:status) { system(command, out: File::NULL) }

  after { FileUtils.rm_rf("tmp/test_app") }

  context "with edge argument" do
    let(:command) { "bin/decidim --edge tmp/test_app" }

    it "successfully generates application" do
      expect(status).to eq(true)
    end
  end

  context "with branch argument" do
    let(:command) { "bin/decidim --branch master tmp/test_app" }

    it "successfully generates application" do
      expect(status).to eq(true)
    end
  end

  context "with path argument" do
    let(:command) { "bin/decidim --path #{File.expand_path("..", __dir__)} tmp/test_app" }

    it "successfully generates application" do
      expect(status).to eq(true)
    end
  end

  context "development application" do
    let(:command) { "rake development_app" }

    it "successfully generates application" do
      expect(status).to eq(true)
    end
  end
end
