# frozen_string_literal: true

require "spec_helper"
require "better_html"
require "better_html/parser"
require "erb_lint"
require "erb_lint/file_loader"
require "erb_lint/processed_source"
require "erb_lint/runner_config"
require "erb_lint/linters/admin_page_title_linter"

RSpec.describe ERBLint::Linters::AdminPageTitleLinter do
  let(:file_loader) { ERBLint::FileLoader.new(Dir.pwd) }
  let(:runner_config) { ERBLint::RunnerConfig.new("linters" => { "AdminPageTitleLinter" => { "enabled" => true } }) }
  let(:linter) { described_class.new(file_loader, runner_config.for_linter(described_class)) }

  def run_for(filename, content)
    processed_source = ERBLint::ProcessedSource.new(filename, content)
    linter.clear_offenses
    linter.run(processed_source)
    linter.offenses
  end

  it "adds an offense when missing the admin title line" do
    offenses = run_for(
      "decidim-admin/app/views/decidim/admin/users/index.html.erb",
      "<div>Missing title</div>\n"
    )

    expect(offenses.length).to eq(1)
    expect(offenses.first.message).to include("Admin views must start with: <% add_decidim_page_title(t(\".title\")) %>")
  end

  it "does not add an offense when title line is first" do
    offenses = run_for(
      "decidim-admin/app/views/decidim/admin/users/index.html.erb",
      "<% add_decidim_page_title(t(\".title\")) %>\n<div>OK</div>\n"
    )

    expect(offenses).to be_empty
  end

  it "does not add an offense when title line is first with extra trailing whitespace" do
    offenses = run_for(
      "decidim-admin/app/views/decidim/admin/users/index.html.erb",
      "<% add_decidim_page_title(t(\".title\")) %>   \n<div>OK</div>\n"
    )

    expect(offenses).to be_empty
  end

  it "adds an offense when title line is not the first line" do
    offenses = run_for(
      "decidim-admin/app/views/decidim/admin/users/index.html.erb",
      "<div>Intro</div>\n<% add_decidim_page_title(t(\".title\")) %>\n"
    )

    expect(offenses.length).to eq(1)
  end

  it "ignores non-admin views" do
    offenses = run_for(
      "decidim-admin/app/views/decidim/pages/index.html.erb",
      "<div>Page</div>\n"
    )

    expect(offenses).to be_empty
  end

  it "ignores admin partials" do
    offenses = run_for(
      "decidim-admin/app/views/decidim/admin/shared/_form.html.erb",
      "<div>Partial</div>\n"
    )

    expect(offenses).to be_empty
  end

  it "ignores non-ERB templates" do
    offenses = run_for(
      "decidim-admin/app/views/decidim/admin/users/index.html.haml",
      "= add_decidim_page_title(t('.title'))\n"
    )

    expect(offenses).to be_empty
  end

  it "ignores layouts" do
    offenses = run_for(
      "decidim-admin/app/views/decidim/admin/layouts/decidim/admin/application.html.erb",
      "<div>Layout</div>\n"
    )

    expect(offenses).to be_empty
  end

  it "ignores mailer views" do
    offenses = run_for(
      "decidim-admin/app/views/decidim/admin_mailer/welcome.html.erb",
      "<div>Mailer</div>\n"
    )

    expect(offenses).to be_empty
  end

  it "ignores mailer views in admin directories ending with _mailer" do
    offenses = run_for(
      "decidim-conferences/app/views/decidim/conferences/admin/invite_join_conference_mailer/invite.html.erb",
      "<div>Mailer</div>\n"
    )

    expect(offenses).to be_empty
  end

  it "does not add an offense when title line has string interpolation" do
    offenses = run_for(
      "decidim-admin/app/views/decidim/admin/users/index.html.erb",
      "<% add_decidim_page_title(t(\".title\", name: user.name)) %>\n<div>OK</div>\n"
    )

    expect(offenses).to be_empty
  end

  it "adds an offense when the admin title line has a newline before" do
    offenses = run_for(
      "decidim-admin/app/views/decidim/admin/users/index.html.erb",
      "\n<% add_decidim_page_title(t(\".title\")) %>\n<div>Empty new line on first line</div>\n"
    )

    expect(offenses.length).to eq(1)
    expect(offenses.first.message).to include("Admin views must start with: <% add_decidim_page_title(t(\".title\")) %>")
  end
end
