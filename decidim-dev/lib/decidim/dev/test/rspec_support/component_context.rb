# frozen_string_literal: true

shared_examples "has mandatory config setting" do |mandatory_field|
  let(:edit_component_path) do
    Decidim::EngineRouter.admin_proxy(component.participatory_space).edit_component_path(component.id)
  end

  before do
    visit edit_component_path
    component.update(settings: { mandatory_field => "" })
    visit edit_component_path
  end

  it "does not allow updating the component" do
    click_on "Update"

    within ".#{mandatory_field}_container" do
      expect(page).to have_content("There is an error in this field")
    end
  end
end

shared_context "with a component" do
  let(:manifest) { Decidim.find_component_manifest(manifest_name) }
  let(:user) { create(:user, :confirmed, organization:) }

  let!(:organization) { create(:organization, *organization_traits, available_authorizations: %w(dummy_authorization_handler another_dummy_authorization_handler)) }

  let(:participatory_process) do
    create(:participatory_process, :with_steps, organization:)
  end

  let(:participatory_space) { participatory_process }

  let!(:component) do
    create(:component,
           manifest:,
           participatory_space:)
  end

  let!(:category) { create(:category, participatory_space:) }
  let!(:scope) { create(:scope, organization:) }
  let(:root_taxonomy) { create(:taxonomy, organization:) }
  let!(:taxonomy) { create(:taxonomy, organization:, parent: root_taxonomy) }
  let(:taxonomy_filter) { create(:taxonomy_filter, internal_name:, name:, participatory_space_manifests: [participatory_space.manifest.name], root_taxonomy:) }
  let!(:taxonomy_filter_item) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: taxonomy) }
  let(:internal_name) { { "en" => "Internal taxonomy filter name" } }
  let(:name) { { "en" => "Public taxonomy filter name" } }

  let(:organization_traits) { [] }

  before do
    if organization_traits.include?(:secure_context)
      switch_to_secure_context_host
    else
      switch_to_host(organization.host)
    end
  end

  def visit_component
    page.visit main_component_path(component, locale: I18n.locale)
  end
end

shared_context "when managing a component" do
  include_context "with a component" do
    let(:organization_traits) { component_organization_traits }
  end

  let(:current_component) { component }
  let(:component_organization_traits) { [] }

  before do
    login_as user, scope: :user
    visit_component_admin
  end

  def visit_component_admin
    visit manage_component_path(component)
  end

  # Returns the config path for a given component.
  #
  # component - the Component we want to find the root path for.
  #
  # Returns a url.
  def edit_component_path(component)
    Decidim::EngineRouter.admin_proxy(component.participatory_space).edit_component_path(component.id)
  end
end

shared_context "when managing a component as an admin" do
  include_context "when managing a component" do
    let(:component_organization_traits) { admin_component_organization_traits }
  end

  let(:admin_component_organization_traits) { [] }

  let(:user) do
    create(:user,
           :admin,
           :confirmed,
           organization:)
  end
end

shared_context "when managing a component as a process admin" do
  include_context "when managing a component"

  let(:user) do
    create(:process_admin,
           :confirmed,
           organization:,
           participatory_process:)
  end
end

shared_context "when publishing and unpublishing the component" do
  let(:title) { translated(current_component.name) }
  # When resources are being created or modified, the following jobs are enqueued among the ones that we need to wait for.
  # When running in CI, we have situations when job processing takes longer, causing flaky tests.
  # Adding a list of exceptions here, helps us to avoid those situations.
  let(:job_exceptions) do
    [
      Decidim::MachineTranslationResourceJob,
      ActiveStorage::AnalyzeJob
    ]
  end

  context "when component is unpublished" do
    before do
      current_component.unpublish!
      current_component.participatory_space.try_add_to_index_as_search_resource

      visit decidim_admin_participatory_processes.components_path(current_component.participatory_space)
    end

    it "reindexes on publication" do
      Decidim::SearchableResource.where(resource:).delete_all
      expect(Decidim::SearchableResource.where(resource:).count).to be_zero

      within "tr", text: title do
        find("button[data-controller='dropdown']").click
        click_on "Publish"
      end

      expect(page).to have_admin_callout("The component has been successfully published")

      perform_enqueued_jobs(except: job_exceptions)

      expect(Decidim::SearchableResource.where(resource:).count).to be_positive
      expect(component.reload).to be_published
    end
  end

  context "when component is published" do
    before do
      current_component.publish!
      current_component.participatory_space.try_add_to_index_as_search_resource

      visit decidim_admin_participatory_processes.components_path(current_component.participatory_space)
    end

    it "removes records from index" do
      perform_enqueued_jobs(except: job_exceptions)

      expect(Decidim::SearchableResource.where(resource:).count).to be_positive

      within ".sidebar-menu" do
        click_on "Components"
      end

      within "tr", text: title do
        find("button[data-controller='dropdown']").click
        click_on "Hide from menu"
      end

      perform_enqueued_jobs(except: job_exceptions)

      expect(Decidim::SearchableResource.where(resource:).count).to be_positive

      within "tr", text: title do
        find("button[data-controller='dropdown']").click
        click_on "Unpublish"
      end

      expect(page).to have_admin_callout("The component has been successfully unpublished")

      perform_enqueued_jobs(except: job_exceptions)

      expect(Decidim::SearchableResource.where(resource:).count).to be_zero
      expect(current_component.reload).not_to be_published
    end
  end
end

shared_context "when cycling through publication states" do
  include_context "when managing a component as an admin" do
    let(:title) { translated(current_component.name) }

    it "cycles through unpublished and published states successfully" do
      visit decidim_admin_participatory_processes.components_path(current_component.participatory_space)

      within ".sidebar-menu" do
        click_on "Components"
      end

      within "tr", text: title do
        find("button[data-controller='dropdown']").click
        click_on "Hide from menu"
      end

      expect(page).to have_admin_callout("The component has been successfully hidden from the menu.")

      within "tr", text: title do
        find("button[data-controller='dropdown']").click
        click_on "Unpublish"
      end

      expect(page).to have_admin_callout("The component has been successfully unpublished")

      within "tr", text: title do
        find("button[data-controller='dropdown']").click
        click_on "Publish"
      end

      expect(page).to have_admin_callout("The component has been successfully published")
    end
  end
end
