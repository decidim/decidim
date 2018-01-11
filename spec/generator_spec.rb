# frozen_string_literal: true

describe "Application generation" do
  let(:status) do
    Bundler.with_original_env { system(command, out: File::NULL) }
  end

  let(:test_app) { "spec/generator_test_app" }

  after { FileUtils.rm_rf(test_app) }

  shared_examples_for "a sane generator" do
    it "successfully generates application" do
      expect(status).to eq(true)
    end
  end

  # rubocop:disable RSpec/BeforeAfterAll
  before(:all) do
    system("bundle exec rake install_all", out: File::NULL)
  end

  after(:all) do
    system("bundle exec rake uninstall_all", out: File::NULL)
  end
  # rubocop:enable RSpec/BeforeAfterAll

  context "without flags" do
    let(:command) { "decidim #{test_app}" }

    it_behaves_like "a sane generator"
  end

  context "with --edge flag" do
    let(:command) { "decidim --edge #{test_app}" }

    it_behaves_like "a sane generator"
  end

  context "with --branch flag" do
    let(:command) { "decidim --branch master #{test_app}" }

    it_behaves_like "a sane generator"
  end

  context "with --path flag" do
    let(:command) { "decidim --path #{File.expand_path("..", __dir__)} #{test_app}" }

    it_behaves_like "a sane generator"
  end

  context "with development application" do
    let(:command) do
      "decidim --path #{File.expand_path("..", __dir__)} #{test_app} --recreate_db --seed_db"
    end

    it_behaves_like "a sane generator"
  end
end
