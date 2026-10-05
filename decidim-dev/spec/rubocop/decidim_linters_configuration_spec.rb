# frozen_string_literal: true

require "rubocop"
require "yaml"

RSpec.describe "decidim-linters RuboCop configuration" do
  let(:config_path) do
    File.expand_path("../../config/rubocop/decidim-linters/configuration.yml", __dir__)
  end

  let(:configuration) { YAML.safe_load_file(config_path) }

  let(:cop_config) { configuration.fetch("Decidim/OrganizationScopedFinder") }

  let(:include_patterns) { cop_config.fetch("Include") }

  let(:exclude_patterns) { cop_config.fetch("Exclude", []) }

  def matches?(path)
    RuboCop::FilePatterns.from(include_patterns).match?(path)
  end

  def excluded?(path)
    RuboCop::FilePatterns.from(exclude_patterns).match?(path)
  end

  it "matches admin controllers directly inside an admin directory" do
    expect(matches?("decidim-admin/app/controllers/decidim/admin/officializations_controller.rb")).to be(true)
  end

  it "matches nested admin controllers" do
    expect(matches?("decidim-admin/app/controllers/decidim/admin/moderations/reports_controller.rb")).to be(true)
    expect(matches?("decidim-admin/app/controllers/decidim/admin/managed_users/promotions_controller.rb")).to be(true)
  end

  it "matches deeply nested admin controllers" do
    expect(matches?("decidim-admin/app/controllers/decidim/admin/moderations/foo/bar/baz_controller.rb")).to be(true)
  end

  it "matches controllers nested under other modules' admin directories" do
    expect(matches?("decidim-assemblies/app/controllers/decidim/assemblies/admin/moderations/reports_controller.rb")).to be(true)
  end

  it "matches admin concerns" do
    expect(matches?("decidim-admin/app/controllers/decidim/admin/concerns/has_attachments.rb")).to be(true)
    expect(matches?("decidim-admin/app/controllers/concerns/decidim/admin/logs/filterable.rb")).to be(true)
  end

  it "does not match non-admin controllers" do
    expect(matches?("decidim-core/app/controllers/decidim/application_controller.rb")).to be(false)
    expect(matches?("decidim-core/app/controllers/decidim/components/base_controller.rb")).to be(false)
  end

  it "excludes decidim-system controllers" do
    expect(excluded?("decidim-system/app/controllers/decidim/system/tenants_controller.rb")).to be(true)
    expect(excluded?("decidim-admin/app/controllers/decidim/admin/officializations_controller.rb")).to be(false)
  end
end
