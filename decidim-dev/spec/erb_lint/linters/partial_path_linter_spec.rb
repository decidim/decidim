# frozen_string_literal: true

require "spec_helper"
require "better_html"
require "better_html/parser"
require "erb_lint"
require "erb_lint/file_loader"
require "erb_lint/processed_source"
require "erb_lint/runner_config"
require "erb_lint/linters/partial_path_linter"

RSpec.describe ERBLint::Linters::PartialPath do
  let(:file_loader) { ERBLint::FileLoader.new(Dir.pwd) }
  let(:runner_config) { ERBLint::RunnerConfig.new("linters" => { "PartialPath" => { "enabled" => true } }) }
  let(:linter) { described_class.new(file_loader, runner_config.for_linter(described_class)) }

  def run_for(filename, content)
    processed_source = ERBLint::ProcessedSource.new(filename, content)
    linter.clear_offenses
    linter.run(processed_source)
    linter.offenses
  end

  it "adds an offense when a partial is rendered with a relative path that needs to be made full" do
    offenses = run_for(
      "app/views/users/show.html.erb",
      '<%= render "form" %>'
    )

    expect(offenses.length).to eq(1)
    expect(offenses.first.message).to include("Use the full path for partials. Replace `render \"form\"` with `render \"users/form\"`")
  end

  it "does not add an offense when a partial is already using the full path" do
    offenses = run_for(
      "app/views/users/show.html.erb",
      '<%= render "users/form" %>'
    )

    expect(offenses).to be_empty
  end

  it "does not add an offense when the partial is a layout" do
    offenses = run_for(
      "app/views/users/show.html.erb",
      '<%= render "layouts/application" %>'
    )

    expect(offenses).to be_empty
  end

  it "does not add an offense when the partial starts with a slash" do
    offenses = run_for(
      "app/views/users/show.html.erb",
      '<%= render "/shared/form" %>'
    )

    expect(offenses).to be_empty
  end

  it "does not add an offense when the partial contains a slash (but is not a layout)" do
    offenses = run_for(
      "app/views/users/show.html.erb",
      '<%= render "shared/form" %>'
    )

    expect(offenses).to be_empty
  end

  it "does not add an offense when the partial is in an allowed prefix" do
    runner_config_with_prefixes = ERBLint::RunnerConfig.new("linters" => { "PartialPath" => { "enabled" => true, "allowed_prefixes" => ["form"] } })
    linter_with_prefixes = described_class.new(file_loader, runner_config_with_prefixes.for_linter(described_class))

    processed_source = ERBLint::ProcessedSource.new("app/views/users/show.html.erb", '<%= render "form" %>')
    linter_with_prefixes.clear_offenses
    linter_with_prefixes.run(processed_source)

    expect(linter_with_prefixes.offenses).to be_empty
  end

  it "ignores non-ERB templates" do
    offenses = run_for(
      "app/views/users/show.html.haml",
      '= render "form"'
    )

    expect(offenses).to be_empty
  end

  it "ignores files in cells directory" do
    offenses = run_for(
      "app/views/cells/users/show.html.erb",
      '<%= render "form" %>'
    )

    expect(offenses).to be_empty
  end

  it "adds offense with correct position in the line" do
    offenses = run_for(
      "app/views/users/show.html.erb",
      '<div><%= render "form" %></div>'
    )

    expect(offenses.length).to eq(1)
    # The offense should be on the word "form"
    expect(offenses.first.source_range.source).to eq("form")
  end

  it "handles multiple partials in one line" do
    offenses = run_for(
      "app/views/users/show.html.erb",
      '<%= render "form" %> <%= render "form2" %>'
    )

    expect(offenses.length).to eq(2)
    expect(offenses.first.message).to include("Use the full path for partials. Replace `render \"form\"` with `render \"users/form\"`")
    expect(offenses.last.message).to include("Use the full path for partials. Replace `render \"form2\"` with `render \"users/form2\"`")
  end

  it "correctly identifies offense positions for repeated partial paths" do
    offenses = run_for(
      "app/views/users/show.html.erb",
      '<%= render "form" %> <%= render "form" %>'
    )

    expect(offenses.length).to eq(2)
    expect(offenses[0].source_range.source).to eq("form")
    expect(offenses[1].source_range.source).to eq("form")
  end

  it "correctly identifies offense for the second occurrence of the same partial path" do
    content = <<~ERB
      <%= render "form" %>
      <div>some content</div>
      <%= render "form" %>
    ERB
    offenses = run_for("app/views/users/show.html.erb", content)

    expect(offenses.length).to eq(2)
    expect(offenses[0].source_range.source).to eq("form")
    expect(offenses[1].source_range.source).to eq("form")
    expect(offenses[0].source_range.begin_pos).to be < offenses[1].source_range.begin_pos
  end
end
