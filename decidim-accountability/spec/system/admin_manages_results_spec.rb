require "spec_helper"

# TODO: Describe wording? ? "Admin #index"?
describe "Admin manages results", type: :system do
  let(:manifest_name) { "accountability" }

  include_context "when managing a component as an admin"

  #scope: create(:scope, organization: component.organization, name: Decidim::Faker::Localized.word )

  let!(:results) do
    create_list(
      :result,
      3,
      component: current_component
    )
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit_component_admin
  end

  it "shows all results for a given component" do
    results.each do |result|
      expect(page).to have_content(translated(result.title))
    end
  end

  it "orders results by ID" do
    ordered_results = results.sort_by { | result | result.id }.reverse

    click_link "ID"
    rows = page.all("tbody tr")

    rows.each_with_index do |row, i|
      expect(row).to have_text(ordered_results[i].id)
    end
  end

  it "orders results by title" do
    ordered_results = results.sort_by { | result | translated(result.title) }

    click_link "Title"
    rows = page.all("tbody tr")
    rows

    rows.each_with_index do |row, i|
      expect(row).to have_text(translated(ordered_results[i].title))
    end
  end

  it "orders results by category" do
    ordered_results = results.sort_by { | result | translated(result.category.name) }

    click_link "Category"
    rows = page.all("tbody tr")

    rows.each_with_index do |row, i|
      expect(row).to have_text(translated(ordered_results[i].category.name))
    end
  end

  it "orders results by scope" do
    ordered_results = results.sort_by { | result | translated(result.scope.name) }

    click_link "Scope"
    rows = page.all("tbody tr")

    rows.each_with_index do |row, i|
      expect(row).to have_text(translated(ordered_results[i].scope.name))
    end
  end

  it "orders results by status" do
    ordered_results = results.sort_by { | result | translated(result.status.name) }

    click_link "Status"
    rows = page.all("tbody tr")

    rows.each_with_index do |row, i|
      expect(row).to have_text(translated(ordered_results[i].status.name))
    end
  end

  it "orders results by progress" do
    ordered_results = results.sort_by { | result | result.progress }

    click_link "Progress"
    rows = page.all("tbody tr")

    rows.each_with_index do |row, i|
      expect(row).to have_text(ordered_results[i].progress&.to_i)
    end
  end

  it "orders results by created at" do
    ordered_results = results.sort_by { | result | result.created_at }

    click_link "Created"
    rows = page.all("tbody tr")

    rows.each_with_index do |row, i|
      expect(row).to have_text(I18n.l(ordered_results[i].created_at, format: :decidim_short))
    end
  end
end
