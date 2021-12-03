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
             created_at: Time.current - 2.days,
             budget_amount: 10_000),
      create(:project,
             scope: create(:scope, organization: component.organization, name: { "ca" => "Scope3", "en" => "Scope1" }),
             budget: budget,
             category: create(:category, participatory_space: participatory_space),
             created_at: Time.current - 1.day,
             budget_amount: 75_000),
      create(:project,
             scope: create(:scope, organization: component.organization, name: { "ca" => "Scope1", "en" => "Scope2" }),
             budget: budget,
             category: create(:category, participatory_space: participatory_space),
             created_at: Time.current,
             budget_amount: 80_000)
    ]
  end

  let(:users) { create_list(:user, 4, organization: component.organization) }

  let(:orders) do
    [
      create(:order, user: users[0], budget: budget),
      create(:order, user: users[1], budget: budget),
      create(:order, user: users[2], budget: budget),
      create(:order, user: users[3], budget: budget)
    ]
  end

  before do
    visit_component_admin
    find("a[title='Manage projects']").click
  end

  context "when there are votes" do
    before do
      orders[0].projects << projects[0]
      orders[0].projects << projects[2]
      orders[0].save!
      orders[0].update(checked_out_at: Time.current)
      orders[1].projects << projects[2]
      orders[1].save!
      orders[1].update(checked_out_at: Time.current)
      orders[2].projects << projects[2]
      orders[2].save!
      orders[2].update(checked_out_at: Time.current)
      visit current_path
    end

    it "orders projects by votes count" do
      click_link "Votes count"
      rows = page.all("tbody tr")

      expect(rows[0]).to have_text(translated(projects.last.title))
      expect(rows[1]).to have_text(translated(projects.first.title))
      expect(rows[2]).to have_text(translated(projects.second.title))
    end
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

  it "orders projects by scope" do
    ordered_projects = projects.sort_by { |project| translated(project.scope.name) }

    click_link "Scope"
    rows = page.all("tbody tr")

    rows.each_with_index do |row, i|
      expect(row).to have_text(translated(ordered_projects[i].title))
    end
  end
end
