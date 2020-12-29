require "spec_helper"

# Describe wording? ? "Admin #index"?
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

  it "orders results by title" do
    click_link "Title"

    # Create ordered version of results, for comparison with results displayed on page
    ordered_results = results.sort_by { | result | result.title["en"] }
    # Create list of all 'tr' elements found on page.
    rows = page.all("tr")

    for i in 0..9 do
      # Compare the 2nd to 11th table rows found in the view with the results in ordered_results,
      # as the 1st row in the view contains the column headings.
      expect(rows[i + 1]).to have_text(ordered_results[i].title["en"])
    end

    #sleep(5)
  end
end
