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

  it "does not register an offense for finders on value constants" do
    expect_no_offenses(<<~RUBY)
      OPTIONS.first
    RUBY
  end

  it "does not register an offense for finders on namespaced value constants" do
    expect_no_offenses(<<~RUBY)
      Decidim::PAGINATION_OPTIONS.first
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

  it "does not double-offense when where is consumed by a finder through intermediate order" do
    expect_offense(<<~RUBY)
      Template.where(name: "foo").order(:id).first
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "does not double-offense when where is consumed by a finder through intermediate relation calls" do
    expect_offense(<<~RUBY)
      Template.where(name: "foo").order(:id).find_by(id: params[:id])
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "registers an offense for a finder consumed by a block-based find" do
    expect_offense(<<~RUBY)
      Template.first(5).find { |template| template.id == params[:id].to_i }
      ^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "registers an offense for an unscoped finder consumed by an outer scoped non-creation finder" do
    expect_offense(<<~RUBY)
      Template.find_by(id: params[:id]).find_by(organization: current_organization)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "registers an offense when a scoped creation finder follows an unscoped lookup" do
    expect_offense(<<~RUBY)
      Decidim::Taxonomy.find(params[:id]).children.find_or_initialize_by(organization: current_organization)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "registers an offense for an unscoped lookup followed by a scoped relation chain" do
    expect_offense(<<~RUBY)
      Decidim::Taxonomy.find(params[:id]).children.where(organization: current_organization).first
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "registers an offense for an unscoped lookup followed by a scoped relation chain through intermediate calls" do
    expect_offense(<<~RUBY)
      Decidim::Taxonomy.find(params[:id]).children.order(:id).where(organization: current_organization).first
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "accepts a relation chain whose records are only loaded after scoping" do
    expect_no_offenses(<<~RUBY)
      Template.where(name: "foo").where(organization: current_organization).first
    RUBY
  end

  it "accepts a where consumed by a scoped non-creation finder" do
    expect_no_offenses(<<~RUBY)
      Template.where(name: "foo").find_by(organization: current_organization)
    RUBY
  end

  it "accepts a where consumed by a scoped find_or_create_by" do
    expect_no_offenses(<<~RUBY)
      Template.where(name: "foo").find_or_create_by(organization: current_organization)
    RUBY
  end

  it "accepts a where consumed by a scoped find_or_create_by!" do
    expect_no_offenses(<<~RUBY)
      Template.where(name: "foo").find_or_create_by!(organization: current_organization)
    RUBY
  end

  it "accepts a where consumed by a scoped find_or_initialize_by" do
    expect_no_offenses(<<~RUBY)
      Template.where(name: "foo").find_or_initialize_by(organization: current_organization)
    RUBY
  end

  it "accepts a where consumed by a scoped find_or_create_by with a block" do
    expect_no_offenses(<<~RUBY)
      Template.where(name: "foo").find_or_create_by(organization: current_organization) { |template| template.title = "bar" }
    RUBY
  end

  it "accepts a where consumed by a scoped find_or_create_by! with a block" do
    expect_no_offenses(<<~RUBY)
      Template.where(name: "foo").find_or_create_by!(organization: current_organization) { |template| template.title = "bar" }
    RUBY
  end

  it "accepts a where consumed by a scoped find_or_initialize_by with a block" do
    expect_no_offenses(<<~RUBY)
      Template.where(name: "foo").find_or_initialize_by(organization: current_organization) { |template| template.title = "bar" }
    RUBY
  end

  it "registers an offense for a where consumed by an unscoped find_or_create_by with a block" do
    expect_offense(<<~RUBY)
      Template.where(name: "foo").find_or_create_by(name: "bar") { |template| template.title = "bar" }
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "registers an offense for a where loaded before a scoped find_or_create_by with a block" do
    expect_offense(<<~RUBY)
      Template.where(name: "foo").load.find_or_create_by(organization: current_organization) { |template| template.title = "bar" }
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "registers an offense for a where loaded asynchronously before a scoped find_or_create_by with a block" do
    expect_offense(<<~RUBY)
      Template.where(name: "foo").load_async.find_or_create_by(organization: current_organization) { |template| template.title = "bar" }
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "registers an offense for a where loaded before an or consumed by a scoped where" do
    expect_offense(<<~RUBY)
      Template.where(name: "foo").load.or(current_organization.templates).where(organization: current_organization)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "registers an offense for a where loaded before an or consumed by a scoped finder" do
    expect_offense(<<~RUBY)
      Template.where(name: "foo").load.or(current_organization.templates).where(organization: current_organization).first
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "registers an offense for where used as an argument" do
    expect_offense(<<~RUBY)
      current_organization.things.where(value: Template.where(name: "foo"))
                                               ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "registers an offense for where used as an argument to a scoped finder" do
    expect_offense(<<~RUBY)
      current_organization.templates.find_by(id: Template.where(name: "foo"))
                                                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
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

  it "accepts explicit self current_organization scoped find_by" do
    expect_no_offenses(<<~RUBY)
      self.current_organization.templates.find_by(id: params[:id])
    RUBY
  end

  it "accepts explicit self collection scoped find" do
    expect_no_offenses(<<~RUBY)
      self.collection.find(params.expect(:id))
    RUBY
  end

  it "registers an offense for current_organization called on an explicit unsafe_scope receiver" do
    expect_offense(<<~RUBY)
      Template.unsafe_scope.current_organization.find_by(id: params[:id])
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "registers an offense for collection called on an explicit unsafe_scope receiver" do
    expect_offense(<<~RUBY)
      Template.unsafe_scope.collection.find(params.expect(:id))
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
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

  it "accepts where(component: form.current_component).find" do
    expect_no_offenses(<<~RUBY)
      Template.where(component: form.current_component).find(params.expect(:id))
    RUBY
  end

  it "accepts where(component: form.current_component).find with a form argument" do
    expect_no_offenses(<<~RUBY)
      def find_template(form)
        Template.where(component: form.current_component).find(params.expect(:id))
      end
    RUBY
  end

  it "accepts find_or_initialize_by(organization: form.current_organization)" do
    expect_no_offenses(<<~RUBY)
      Template.find_or_initialize_by(organization: form.current_organization, name: "foo")
    RUBY
  end

  it "accepts where(participatory_space: @form.current_participatory_space).first" do
    expect_no_offenses(<<~RUBY)
      Template.where(participatory_space: @form.current_participatory_space).first
    RUBY
  end

  it "registers an offense for a current helper called on an unscoped model chain" do
    expect_offense(<<~RUBY)
      Template.where(component: Template.unsafe_scope.current_component).find(params.expect(:id))
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "registers an offense for a current helper called on an unrelated receiver" do
    expect_offense(<<~RUBY)
      Template.where(component: record.current_component).find(params.expect(:id))
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
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

  it "accepts where(organization: organization).find_by" do
    expect_no_offenses(<<~RUBY)
      Template.where(organization: organization).find_by(id: params[:id])
    RUBY
  end

  it "accepts where(organization: organization).find with an organization argument" do
    expect_no_offenses(<<~RUBY)
      def find_template(organization)
        Template.where(organization: organization).find(id)
      end
    RUBY
  end

  it "accepts where(organization: @user.organization).find_by" do
    expect_no_offenses(<<~RUBY)
      Template.where(organization: @user.organization).find_by(id: params[:id])
    RUBY
  end

  it "accepts Authorizations.new(organization: @user.organization).query.find" do
    expect_no_offenses(<<~RUBY)
      Authorizations.new(organization: @user.organization, name: "foo").query.find(params.expect(:id))
    RUBY
  end

  it "accepts where(organization: record.organization) with a record argument" do
    expect_no_offenses(<<~RUBY)
      def find_template(record)
        Template.where(organization: record.organization).find(params.expect(:id))
      end
    RUBY
  end

  it "accepts where(organization: current_user.organization).find_by" do
    expect_no_offenses(<<~RUBY)
      Template.where(organization: current_user.organization).find_by(id: params[:id])
    RUBY
  end

  it "accepts where(organization: form.organization).find_by" do
    expect_no_offenses(<<~RUBY)
      Template.where(organization: form.organization).find_by(id: params[:id])
    RUBY
  end

  it "registers an offense for where(organization: tenant_resolver.organization(params[:organization_id]))" do
    expect_offense(<<~RUBY)
      Template.where(organization: tenant_resolver.organization(params[:organization_id]))
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "registers an offense for where(organization: tenant_resolver.organization)" do
    expect_offense(<<~RUBY)
      Template.where(organization: tenant_resolver.organization)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "registers an offense for where(organization: params[:organization_id].organization)" do
    expect_offense(<<~RUBY)
      Template.where(organization: params[:organization_id].organization)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "registers an offense for where(organization: Organization.find(params[:id]).organization)" do
    expect_offense(<<~RUBY)
      Template.where(organization: Organization.find(params[:id]).organization)
                                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "registers an offense for where(organization: params[:id])" do
    expect_offense(<<~RUBY)
      Template.where(organization: params[:id])
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "accepts current_organization scoped find" do
    expect_no_offenses(<<~RUBY)
      current_organization.users.find(params.expect(:id))
    RUBY
  end

  it "accepts a query object constructed with current_organization" do
    expect_no_offenses(<<~RUBY)
      OrganizationAssemblies.new(current_organization).query.where(slug: params[:slug]).first!
    RUBY
  end

  it "accepts two query objects constructed with current_organization combined with or" do
    expect_no_offenses(<<~RUBY)
      OrganizationAssemblies.new(current_organization).query.where(slug: params[:slug]).or(
        OrganizationAssemblies.new(current_organization).query.where(id: params[:slug])
      ).first!
    RUBY
  end

  it "accepts an or relation mixing a query object and a current_organization scoped relation" do
    expect_no_offenses(<<~RUBY)
      OrganizationAssemblies.new(current_organization).query.or(current_organization.assemblies.where(id: params[:id])).first!
    RUBY
  end

  it "accepts an or relation with a helper filtering by the current component" do
    expect_no_offenses(<<~RUBY)
      Meeting
        .includes(:taxonomies)
        .where(component: current_component)
        .published
        .not_hidden
        .or(MeetingLink.find_meetings(component: current_component))
        .visible_for(current_user)
    RUBY
  end

  it "registers an offense when one or branch is constructed without the current organization" do
    expect_offense(<<~RUBY)
      OrganizationAssemblies.new(current_organization).query.or(OrganizationAssemblies.new(params[:organization_id]).query).first!
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "registers an offense when a nested or branch is not organization scoped" do
    expect_offense(<<~RUBY)
      OrganizationAssemblies.new(current_organization).query.or(current_organization.assemblies.or(OrganizationAssemblies.new(params[:organization_id]).query)).first!
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "accepts nested or branches that are all organization scoped" do
    expect_no_offenses(<<~RUBY)
      OrganizationAssemblies.new(current_organization).query.or(current_organization.assemblies.or(current_organization.participatory_processes)).first!
    RUBY
  end

  it "registers an offense for an or relation with an unscoped branch that is not a model constant" do
    expect_offense(<<~RUBY)
      taxonomies.roots.or(taxonomies.where(id: available_taxonomy_ids))
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "registers an offense for an unscoped or branch consumed by a finder without a model constant" do
    expect_offense(<<~RUBY)
      current_organization.taxonomies.or(Decidim::Taxonomy.all).find(params[:id])
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "registers an offense for an unscoped or branch consumed by a finder through intermediate calls" do
    expect_offense(<<~RUBY)
      current_organization.taxonomies.or(Decidim::Taxonomy.all).order(:id).first
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "accepts a scoped or relation consumed by a finder through intermediate calls" do
    expect_no_offenses(<<~RUBY)
      current_organization.taxonomies.or(current_organization.other_taxonomies).order(:id).first
    RUBY
  end

  it "registers an offense for a query object constructed with untrusted arguments" do
    expect_offense(<<~RUBY)
      OrganizationAssemblies.new(params[:organization_id]).query.where(slug: params[:slug]).first!
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
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

  it "registers an offense for an organization-scoped key with untrusted value in find_by" do
    expect_offense(<<~RUBY)
      Template.find_by(organization_id: params[:organization_id])
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "accepts where(value uses current_component through nested receiver).find" do
    expect_no_offenses(<<~RUBY)
      Project.joins(:budget).where(budget: { component: current_component }).find(params.expect(:id))
    RUBY
  end

  it "accepts nested ownership paths ending in a scoped association" do
    expect_no_offenses(<<~RUBY)
      Project.joins(:budget).where(budget: { project: { component: current_component } }).find(params.expect(:id))
    RUBY
  end

  it "registers an offense for a trusted pair nested under an unrelated association" do
    expect_offense(<<~RUBY)
      Template.where(unrelated: { organization_id: current_organization.id }).find(params[:id])
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "registers an offense for where value uses current_organization.participatory_spaces on an unrelated key" do
    expect_offense(<<~RUBY)
      Component.where(participatory_space: current_organization.participatory_spaces).find(params.expect(:component_id))
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "accepts a finder chained to a scope built with the current organization argument" do
    expect_no_offenses(<<~RUBY)
      Decidim::ContentBlock.for_scope(:homepage, organization: current_organization).where(scoped_resource_id: 1)
    RUBY
  end

  it "registers an offense for a finder chained to a scope built with untrusted arguments" do
    expect_offense(<<~RUBY)
      Widget.custom_scope(name: params[:name]).find_by(id: params[:id])
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "registers an offense for unscoped Model.last" do
    expect_offense(<<~RUBY)
      Template.last
      ^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "registers an offense for unscoped Model.last!" do
    expect_offense(<<~RUBY)
      Template.last!
      ^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "registers an offense for unscoped Model.sole" do
    expect_offense(<<~RUBY)
      Template.sole
      ^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "registers an offense for unscoped Model.sole!" do
    expect_offense(<<~RUBY)
      Template.sole!
      ^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "registers an offense for unscoped Model.find_sole_by" do
    expect_offense(<<~RUBY)
      Template.find_sole_by(id: params[:id])
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "registers an offense for unscoped Model.find_or_initialize_by" do
    expect_offense(<<~RUBY)
      Template.find_or_initialize_by(name: "foo")
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "registers an offense for unscoped Model.find_or_create_by" do
    expect_offense(<<~RUBY)
      Template.find_or_create_by(name: "foo")
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "registers an offense for unscoped Model.find_or_create_by!" do
    expect_offense(<<~RUBY)
      Template.find_or_create_by!(name: "foo")
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "accepts Model.find_or_create_by! with the current organization argument" do
    expect_no_offenses(<<~RUBY)
      Template.find_or_create_by!(organization: current_organization, name: "foo")
    RUBY
  end

  it "accepts a scoped last from the current_organization" do
    expect_no_offenses(<<~RUBY)
      current_organization.templates.last
    RUBY
  end

  it "registers an offense for where value uses current_participatory_space on an unrelated key" do
    expect_offense(<<~RUBY)
      InitiativesCommitteeMember.where(initiative: current_participatory_space).find(params.expect(:id))
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "registers a single offense when an unscoped or branch is followed by where" do
    expect_offense(<<~RUBY)
      current_organization.taxonomies.or(Decidim::Taxonomy.all).order(:id).where(name: "x")
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "registers a single offense when a finder is chained after an unscoped or branch" do
    expect_offense(<<~RUBY)
      current_organization.taxonomies.or(Decidim::Taxonomy.all).order(:id).first(5).first
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  [
    :second, :second!, :third, :third!, :fourth, :fourth!, :fifth, :fifth!,
    :forty_two, :forty_two!, :third_to_last, :third_to_last!, :second_to_last, :second_to_last!,
    :exists?, :any?, :many?, :none?, :one?,
    :first_or_create, :first_or_create!, :first_or_initialize,
    :create_or_find_by, :create_or_find_by!,
    :destroy, :destroy_all, :delete, :delete_all, :update_all, :touch_all, :destroy_by, :delete_by
  ].each do |method|
    it "registers an offense for unscoped Model.#{method}" do
      source = "Template.#{method}"
      carets = "^" * source.length
      expect_offense(<<~RUBY)
        #{source}
        #{carets} Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
      RUBY
    end
  end

  it "accepts predicates on an organization-scoped relation" do
    expect_no_offenses(<<~RUBY)
      current_organization.templates.exists?
      current_organization.templates.any?
      current_organization.templates.many?
      current_organization.templates.none?
      current_organization.templates.one?
    RUBY
  end

  it "accepts destructive methods on an organization-scoped relation" do
    expect_no_offenses(<<~RUBY)
      Template.where(organization: current_organization).update_all(name: "foo")
      Template.where(organization: current_organization).touch_all
      Template.where(organization: current_organization).destroy_by(name: "foo")
      Template.where(organization: current_organization).delete_by(name: "foo")
      current_organization.templates.delete_all
      current_organization.templates.destroy_all
    RUBY
  end

  it "registers an offense for a where consumed by first_or_create with write-only organization arguments" do
    expect_offense(<<~RUBY)
      Template.where(name: "foo").first_or_create(organization: current_organization)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "registers an offense for a where consumed by first_or_create with a block" do
    expect_offense(<<~RUBY)
      Template.where(name: "foo").first_or_create(organization: current_organization) { |template| template.title = "bar" }
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "registers an offense for a where consumed by first_or_initialize with write-only organization arguments" do
    expect_offense(<<~RUBY)
      Template.where(name: "foo").first_or_initialize(organization: current_organization)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "registers an offense for a where consumed by update_all with write-only organization arguments" do
    expect_offense(<<~RUBY)
      Template.where(name: "foo").update_all(decidim_organization_id: current_organization.id)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "registers an offense for update_all with write-only organization arguments" do
    expect_offense(<<~RUBY)
      Template.update_all(organization: current_organization)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "accepts a where consumed by a scoped create_or_find_by!" do
    expect_no_offenses(<<~RUBY)
      Template.where(name: "foo").create_or_find_by!(organization: current_organization)
    RUBY
  end

  it "accepts a query object built with current_user" do
    expect_no_offenses(<<~RUBY)
      AssembliesWithUserRole.for(current_user).any?
    RUBY
  end

  it "accepts a query object built with current_organization" do
    expect_no_offenses(<<~RUBY)
      TaxonomyFilter.for(current_organization).where(id: current_component.settings.taxonomy_filters)
    RUBY
  end

  it "registers an offense for a query object built with an untrusted argument" do
    expect_offense(<<~RUBY)
      AssembliesWithUserRole.for(params[:user_id]).any?
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "registers an offense when a model method only excludes the current user" do
    expect_offense(<<~RUBY)
      Decidim::User.excluding(current_user).first
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "does not register an offense for query-like methods on non-model constants" do
    expect_no_offenses(<<~RUBY)
      File.extname("foo.txt").delete(".")
      File.delete("foo.txt")
      Time.current.second
      Rails.cache.delete(:foo)
      Decidim.participatory_space_manifests.any?
    RUBY
  end

  it "does not register an offense for query-like methods on the Doorkeeper module itself" do
    expect_no_offenses(<<~RUBY)
      Doorkeeper.config.scopes.all
    RUBY
  end

  it "registers an offense for unscoped Doorkeeper credential lookups" do
    expect_offense(<<~RUBY)
      Doorkeeper::Application.find_by(id: params[:id])
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
      Doorkeeper::AccessToken.find_by(token: params[:token])
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
      Doorkeeper::AccessGrant.find_by(token: params[:token])
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unscoped ActiveRecord finder detected. Scope the query to the current organization, e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`.
    RUBY
  end

  it "accepts organization-scoped Doorkeeper credential lookups" do
    expect_no_offenses(<<~RUBY)
      Doorkeeper::Application.find_by(organization: current_organization, id: params[:id])
      Doorkeeper::AccessToken.find_by(organization: current_organization, token: params[:token])
      Doorkeeper::AccessGrant.find_by(organization: current_organization, token: params[:token])
    RUBY
  end
end
