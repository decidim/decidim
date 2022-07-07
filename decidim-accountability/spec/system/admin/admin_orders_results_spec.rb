# frozen_string_literal: true

require "spec_helper"

describe "Admin orders results", type: :system do
  let(:manifest_name) { "accountability" }
  let!(:results) do
    [
      create(:result, scope: create(:scope, organization: component.organization,
                                            name: { "ca" => "Scope2", "en" => "Scope3" }),
                      component: current_component,
                      category: create(:category, participatory_space: participatory_space),
                      created_at: 2.days.ago),
      create(:result, scope: create(:scope, organization: component.organization,
                                            name: { "ca" => "Scope3", "en" => "Scope1" }),
                      component: current_component,
                      category: create(:category, participatory_space: participatory_space),
                      created_at: 1.day.ago),
      create(:result, scope: create(:scope, organization: component.organization,
                                            name: { "ca" => "Scope1", "en" => "Scope2" }),
                      component: current_component,
                      category: create(:category, participatory_space: participatory_space),
                      created_at: Time.current)
    ]
  end

  include_context "when managing a component as an admin"

  it "orders results by ID" do
    ordered_results = results.sort_by(&:id).reverse

    click_link "ID"
    rows = page.all("tbody tr")

    rows.each_with_index do |row, i|
      expect(row).to have_text(translated(ordered_results[i].title))
    end
  end

  it "orders results by title" do
    ordered_results = results.sort_by { |result| translated(result.title) }

    click_link "Title"
    rows = page.all("tbody tr")

    rows.each_with_index do |row, i|
      expect(row).to have_text(translated(ordered_results[i].title))
    end
  end

  it "orders results by category" do
    ordered_results = results.sort_by { |result| translated(result.category.name) }

    click_link "Category"
    rows = page.all("tbody tr")

    rows.each_with_index do |row, i|
      expect(row).to have_text(translated(ordered_results[i].title))
    end
  end

  it "orders results by scope" do
    ordered_results = results.sort_by { |result| translated(result.scope.name) }

    click_link "Scope"
    rows = page.all("tbody tr")

    rows.each_with_index do |row, i|
      expect(row).to have_text(translated(ordered_results[i].title))
    end
  end

  it "orders results by status" do
    ordered_results = results.sort_by { |result| translated(result.status.name) }

    click_link "Status"
    rows = page.all("tbody tr")

    rows.each_with_index do |row, i|
      expect(row).to have_text(translated(ordered_results[i].title))
    end
  end

  it "orders results by progress" do
    ordered_results = results.sort_by(&:progress)

    click_link "Progress"
    rows = page.all("tbody tr")

    rows.each_with_index do |row, i|
      expect(row).to have_text(translated(ordered_results[i].title))
    end
  end

  it "orders results by created at" do
    ordered_results = results.sort_by(&:created_at)

    click_link "Created"
    rows = page.all("tbody tr")

    rows.each_with_index do |row, i|
      expect(row).to have_text(translated(ordered_results[i].title))
    end
  end
end
