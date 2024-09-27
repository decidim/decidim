# frozen_string_literal: true

require "spec_helper"

describe "Admin orders results" do
  let(:manifest_name) { "accountability" }
  let!(:results) do
    [
      create(:result, taxonomies: [create(:taxonomy, :with_parent, organization: component.organization,
                                                                   name: { "ca" => "Taxonomy3", "en" => "Taxonomy3" })],
                      component: current_component,
                      created_at: 2.days.ago),
      create(:result, taxonomies: [create(:taxonomy, :with_parent, organization: component.organization,
                                                                   name: { "ca" => "Taxonomy1", "en" => "Taxonomy1" })],
                      component: current_component,
                      created_at: 1.day.ago),
      create(:result, taxonomies: [create(:taxonomy, :with_parent, organization: component.organization,
                                                                   name: { "ca" => "Taxonomy2", "en" => "Taxonomy2" })],
                      component: current_component,
                      created_at: Time.current)
    ]
  end

  include_context "when managing a component as an admin"

  it "orders results by ID" do
    ordered_results = results.sort_by(&:id).reverse

    click_on "ID"
    rows = page.all("tbody tr")

    rows.each_with_index do |row, i|
      expect(row).to have_text(translated(ordered_results[i].title))
    end
  end

  it "orders results by title" do
    ordered_results = results.sort_by { |result| translated(result.title) }

    click_on "Title"
    rows = page.all("tbody tr")

    rows.each_with_index do |row, i|
      expect(row).to have_text(translated(ordered_results[i].title))
    end
  end

  it "orders results by taxonomy" do
    ordered_results = results.sort_by { |result| translated(result.taxonomies.first.name) }

    click_on "Taxonomies"
    rows = page.all("tbody tr")

    rows.each_with_index do |row, i|
      expect(row).to have_text(translated(ordered_results[i].title))
    end
  end

  it "orders results by status" do
    ordered_results = results.sort_by { |result| translated(result.status.name) }

    click_on "Status"
    rows = page.all("tbody tr")

    rows.each_with_index do |row, i|
      expect(row).to have_text(translated(ordered_results[i].title))
    end
  end

  it "orders results by progress" do
    ordered_results = results.sort_by(&:progress)

    click_on "Progress"
    rows = page.all("tbody tr")

    rows.each_with_index do |row, i|
      expect(row).to have_text(translated(ordered_results[i].title))
    end
  end

  it "orders results by created at" do
    ordered_results = results.sort_by(&:created_at)

    click_on "Created"
    rows = page.all("tbody tr")

    rows.each_with_index do |row, i|
      expect(row).to have_text(translated(ordered_results[i].title))
    end
  end
end
