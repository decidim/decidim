# frozen_string_literal: true

require "spec_helper"

describe "Admin orders projects", type: :system do
  include_context "when managing a component as an admin"
  let(:manifest_name) { "budgets" }
  let(:budget) { create(:budget, component: current_component, total_budget: 100_000) }
  let!(:projects) do
    [
      create(:project,
             scope: create(:scope, organization: component.organization, name: { "ca" => "Scope2", "en" => "Scope3" }),
             budget: budget,
             category: create(:category, participatory_space: participatory_space),
             created_at: 2.days.ago,
             budget_amount: 10_000),
      create(:project,
             scope: create(:scope, organization: component.organization, name: { "ca" => "Scope3", "en" => "Scope1" }),
             budget: budget,
             category: create(:category, participatory_space: participatory_space),
             created_at: 1.day.ago,
             budget_amount: 75_000),
      create(:project,
             scope: create(:scope, organization: component.organization, name: { "ca" => "Scope1", "en" => "Scope2" }),
             budget: budget,
             category: create(:category, participatory_space: participatory_space),
             created_at: Time.current,
             budget_amount: 80_000,
             selected_at: Time.current)
    ]
  end

  before do
    visit_component_admin
    find("a[title='Manage projects']").click
  end

  it "orders projects by ID" do
    ordered_projects = projects.sort_by(&:id).reverse

    click_link "ID"
    rows = page.all("tbody tr")

    rows.each_with_index do |row, i|
      expect(row).to have_text(translated(ordered_projects[i].title))
    end
  end

  it "orders projects by title" do
    ordered_projects = projects.sort_by { |project| translated(project.title) }

    click_link "Title"
    rows = page.all("tbody tr")

    rows.each_with_index do |row, i|
      expect(row).to have_text(translated(ordered_projects[i].title))
    end
  end

  it "orders projects by category" do
    ordered_projects = projects.sort_by { |project| translated(project.category.name) }

    click_link "Category"
    rows = page.all("tbody tr")

    rows.each_with_index do |row, i|
      expect(row).to have_text(translated(ordered_projects[i].category.name))
    end
  end

  it "orders projects by scope" do
    ordered_projects = projects.sort_by { |project| translated(project.scope.name) }

    click_link "Scope"
    rows = page.all("tbody tr")

    rows.each_with_index do |row, i|
      expect(row).to have_text(translated(ordered_projects[i].title))
    end
  end

  it "orders projects by selected" do
    click_link "Selected"
    rows = page.all("tbody tr")

    expect(rows[0]).to have_text(translated(projects[2].title))
  end

  context "when there are votes" do
    let(:users) { create_list(:user, 6, organization: component.organization) }

    let(:orders) do
      [
        create(:order, user: users[0], budget: budget),
        create(:order, user: users[1], budget: budget),
        create(:order, user: users[2], budget: budget),
        create(:order, user: users[3], budget: budget),
        create(:order, user: users[4], budget: budget),
        create(:order, user: users[5], budget: budget)
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
      click_link "Votes count"
      rows = page.all("tbody tr")

      expect(rows[0]).to have_text(translated(projects.second.title))
      expect(rows[1]).to have_text(translated(projects.first.title))
      expect(rows[2]).to have_text(translated(projects.last.title))
    end
  end
end
