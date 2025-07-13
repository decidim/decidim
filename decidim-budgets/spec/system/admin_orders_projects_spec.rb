# frozen_string_literal: true

require "spec_helper"

describe "Admin orders projects" do
  include_context "when managing a component as an admin"
  let(:manifest_name) { "budgets" }
  let(:budget) { create(:budget, component: current_component, total_budget: 100_000) }
  let!(:projects) do
    [
      create(:project,
             taxonomies: [create(:taxonomy, :with_parent, organization: component.organization, name: { "ca" => "Taxonomy3", "en" => "Taxonomy3" })],
             budget:,
             created_at: 2.days.ago,
             budget_amount: 10_000),
      create(:project,
             budget:,
             taxonomies: [create(:taxonomy, :with_parent, organization: component.organization, name: { "ca" => "Taxonomy1", "en" => "Taxonomy1" })],
             created_at: 1.day.ago,
             budget_amount: 75_000),
      create(:project,
             budget:,
             taxonomies: [create(:taxonomy, :with_parent, organization: component.organization, name: { "ca" => "Taxonomy2", "en" => "Taxonomy2" })],
             created_at: Time.current,
             budget_amount: 80_000,
             selected_at: Time.current)
    ]
  end

  before do
    visit_component_admin
    within "tr", text: translated_attribute(budget.title) do
      find("button[data-component='dropdown']").click
      click_on "Manage projects"
    end
  end

  it "orders projects by ID" do
    ordered_projects = projects.sort_by(&:id).reverse

    click_on "ID"
    rows = page.all("tbody tr")

    rows.each_with_index do |row, i|
      expect(row).to have_text(translated(ordered_projects[i].title))
    end
  end

  it "orders projects by title" do
    ordered_projects = projects.sort_by { |project| translated(project.title) }

    click_on "Title"
    rows = page.all("tbody tr")

    rows.each_with_index do |row, i|
      expect(row).to have_text(translated(ordered_projects[i].title))
    end
  end

  it "orders projects by taxonomy" do
    ordered_projects = projects.sort_by { |project| translated(project.taxonomies.first.name) }

    click_on "Taxonomies"
    rows = page.all("tbody tr")

    rows.each_with_index do |row, i|
      expect(row).to have_text(translated(ordered_projects[i].title))
    end
  end

  it "orders projects by selected" do
    click_on "Selected"
    rows = page.all("tbody tr")

    expect(rows[0]).to have_text(translated(projects[2].title))
  end

  context "when there are votes" do
    let(:users) { create_list(:user, 6, organization: component.organization) }

    let(:orders) do
      [
        create(:order, user: users[0], budget:),
        create(:order, user: users[1], budget:),
        create(:order, user: users[2], budget:),
        create(:order, user: users[3], budget:),
        create(:order, user: users[4], budget:),
        create(:order, user: users[5], budget:)
      ]
    end

    before do
      # projects[2] has 3 votes
      # projects[1] has 0 votes
      # projects[0] has 1 vote and 3 pending votes
      orders[0].projects << projects[0]
      orders[0].projects << projects[2]
      orders[1].projects << projects[2]
      orders[2].projects << projects[2]
      orders[3].projects << projects[0]
      orders[4].projects << projects[0]
      orders[5].projects << projects[0]
      orders.each(&:save!)
      orders.take(3).each { |order| order.update!(checked_out_at: Time.current) }
      visit current_path
    end

    it "orders projects by votes count" do
      click_on "Votes count"
      rows = page.all("tbody tr")

      expect(rows[0]).to have_text(translated(projects.second.title))
      expect(rows[1]).to have_text(translated(projects.first.title))
      expect(rows[2]).to have_text(translated(projects.last.title))
    end
  end
end
