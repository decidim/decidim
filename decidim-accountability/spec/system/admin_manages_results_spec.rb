require "spec_helper"

# TODO: Describe wording? ? "Admin #index"?
describe "Admin manages results", type: :system do
  let(:manifest_name) { "accountability" }

  # Custom context created in decidim-accountability/spec/shared/shared_context.rb
  include_context "when managing results as an admin"

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
    rows = page.all("tr")

    for i in 0..9 do
      expect(rows[i + 1]).to have_text(ordered_results[i].id)
    end
  end

  it "orders results by title" do
    ordered_results = results.sort_by { | result | result.title["en"] }

    click_link "Title"
    rows = page.all("tr")

    for i in 0..9 do
      expect(rows[i + 1]).to have_text(ordered_results[i].title["en"])
    end
  end

  # it "orders results by category" do
  #   ordered_results = results.sort_by { | result | result.category }

  #   click_link "Category"
  #   rows = page.all("tr")

  #   for i in 0..9 do
  #     expect(rows[i + 1]).to have_text(ordered_results[i].category)
  #   end
  # end

  # it "orders results by scope" do
  #   ordered_results = results.sort_by { | result | result.scope }

  #   click_link "Scope"
  #   rows = page.all("tr")

  #   for i in 0..9 do
  #     expect(rows[i + 1]).to have_text(ordered_results[i].scope.name["en"])
  #   end
  #   sleep(5)
  # end

  it "orders results by status" do
    ordered_results = results.sort_by { | result | result.status.name["en"] }

    click_link "Status"
    rows = page.all("tr")

    for i in 0..9 do
      expect(rows[i + 1]).to have_text(ordered_results[i].status.name["en"])
    end
  end

  it "orders results by progress" do
    ordered_results = results.sort_by { | result | result.progress }

    click_link "Progress"
    rows = page.all("tr")

    for i in 0..9 do
      expect(rows[i + 1]).to have_text(ordered_results[i].progress&.to_i)
    end
  end

  it "orders results by created at date" do
    ordered_results = results.sort_by { | result | result.created_at }

    click_link "Created"
    rows = page.all("tr")

    for i in 0..9 do
      expect(rows[i + 1]).to have_text(I18n.l(ordered_results[i].created_at, format: :decidim_short))
    end
  end
end
