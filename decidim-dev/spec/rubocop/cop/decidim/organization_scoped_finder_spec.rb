# frozen_string_literal: true

require "rubocop"
require "rubocop/rspec/support"
require "decidim/dev/rubocop/cop/decidim/organization_scoped_finder"

RSpec.describe RuboCop::Cop::Decidim::OrganizationScopedFinder, :config, type: :cop do
  it "registers an offense for unscoped Model.find" do
    expect_offense(<<~RUBY)
      Template.find(params.expect(:id))
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "registers an offense for unscoped Model.find_by" do
    expect_offense(<<~RUBY)
      Template.find_by(id: params[:id])
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "registers an offense for unscoped namespaced Model.find_by" do
    expect_offense(<<~RUBY)
      Decidim::Templates::Template.find_by(id: params[:id])
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "registers an offense for unscoped Model.where(...).first" do
    expect_offense(<<~RUBY)
      Template.where(name: "foo").first
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "registers an offense for unscoped Model.where(...).take" do
    expect_offense(<<~RUBY)
      Template.where(name: "foo").take
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "registers an offense for unscoped Model.where without a terminal finder" do
    expect_offense(<<~RUBY)
      Template.where(name: "foo")
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "does not double-offense when where is consumed by a finder" do
    expect_offense(<<~RUBY)
      Template.where(name: "foo").find_by(id: params[:id])
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "accepts current_organization scoped find_by" do
    expect_no_offenses(<<~RUBY)
      current_organization.templates.find_by(id: params[:id])
    RUBY
  end

  it "accepts collection scoped find" do
    expect_no_offenses(<<~RUBY)
      collection.find(params.expect(:id))
    RUBY
  end

  it "accepts explicit decidim_organization_id scoping in find_by" do
    expect_no_offenses(<<~RUBY)
      Template.where(decidim_organization_id: current_organization.id).find_by(id: params[:id])
    RUBY
  end

  it "accepts current_organization scoped namespaced find_by" do
    expect_no_offenses(<<~RUBY)
      current_organization.templates.where(target: :proposal_answer).find_by(id: params[:id])
    RUBY
  end

  it "accepts where(current_organization: current_organization).first" do
    expect_no_offenses(<<~RUBY)
      Template.where(current_organization: current_organization).first
    RUBY
  end

  it "accepts where(current_component: current_component).find_by" do
    expect_no_offenses(<<~RUBY)
      Template.where(current_component: current_component).find_by(id: params[:id])
    RUBY
  end

  it "accepts where(component: current_component).find" do
    expect_no_offenses(<<~RUBY)
      Template.where(component: current_component).find(params.expect(:id))
    RUBY
  end

  it "accepts Authorizations.new(organization: current_organization).query.find" do
    expect_no_offenses(<<~RUBY)
      Authorizations.new(organization: current_organization, name: "foo", granted: false).query.find(params.expect(:id))
    RUBY
  end

  it "registers an offense for unscoped Authorizations.new.query.find without organization argument" do
    expect_offense(<<~RUBY)
      Authorizations.new(name: "foo", granted: false).query.find(params.expect(:id))
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "accepts current_organization scoped find" do
    expect_no_offenses(<<~RUBY)
      current_organization.users.find(params.expect(:id))
    RUBY
  end

  it "registers an offense for a scoped value on an unrelated key" do
    expect_offense(<<~RUBY)
      Template.where(foo: current_organization)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "registers an offense for an organization-scoped key using untrusted input" do
    expect_offense(<<~RUBY)
      Template.where(decidim_organization_id: params[:id])
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "accepts where(value uses current_component through nested receiver).find" do
    expect_no_offenses(<<~RUBY)
      Project.joins(:budget).where(budget: { component: current_component }).find(params.expect(:id))
    RUBY
  end

  it "registers an offense for where value uses current_organization.participatory_spaces on an unrelated key" do
    expect_offense(<<~RUBY)
      Component.where(participatory_space: current_organization.participatory_spaces).find(params.expect(:component_id))
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "registers an offense for where value uses current_participatory_space on an unrelated key" do
    expect_offense(<<~RUBY)
      InitiativesCommitteeMember.where(initiative: current_participatory_space).find(params.expect(:id))
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end
end
