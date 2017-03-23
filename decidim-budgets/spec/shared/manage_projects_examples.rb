# -*- coding: utf-8 -*-
# frozen_string_literal: true
RSpec.shared_examples "manage projects" do
  it "updates a project" do
    within find("tr", text: translated(project.title)) do
      find("a.action-icon--edit").click
    end

    within ".edit_project" do
      fill_in_i18n(
        :project_title,
        "#title-tabs",
        en: "My new title",
        es: "Mi nuevo título",
        ca: "El meu nou títol"
      )

      find("*[type=submit]").click
    end

    within ".callout-wrapper" do
      expect(page).to have_content("successfully")
    end

    within "table" do
      expect(page).to have_content("My new title")
    end
  end

  context "previewing projects" do
    it "allows the user to preview the project" do
      new_window = window_opened_by { click_link translated(project.title) }

      within_window new_window do
        expect(current_path).to eq decidim_budgets.project_path(id: project.id, participatory_process_id: participatory_process.id, feature_id: current_feature.id)
        expect(page).to have_content(translated(project.title))
      end
    end
  end

  context "seeing finished and pending orders" do
    let!(:project) { create(:project, budget: 70_000_000, feature: current_feature) }

    let!(:finished_orders) do
      orders = create_list(:order, 10, feature: current_feature)
      orders.each do |order|
        order.update_attribute(:line_items, [create(:line_item, project: project, order: order)])
        order.update_attribute(:checked_out_at, Date.today)
      end
    end

    let!(:pending_orders) do
      create_list(:order, 5, feature: current_feature, checked_out_at: nil)
    end

    it "shows the order count" do
      visit current_path
      expect(page).to have_content("Finished orders: 10")
      expect(page).to have_content("Pending orders: 5")
    end
  end

  it "creates a new project" do
    click_link "New Project"

    within ".new_project" do
      fill_in_i18n(
        :project_title,
        "#title-tabs",
        en: "My project",
        es: "Mi proyecto",
        ca: "El meu projecte"
      )
      fill_in_i18n_editor(
        :project_description,
        "#description-tabs",
        en: "A longer description",
        es: "Descripción más larga",
        ca: "Descripció més llarga"
      )
      fill_in :project_budget, with: 22_000_000

      select scope.name, from: :project_decidim_scope_id
      select translated(category.name), from: :project_decidim_category_id

      find("*[type=submit]").click
    end

    within ".callout-wrapper" do
      expect(page).to have_content("successfully")
    end

    within "table" do
      expect(page).to have_content("My project")
    end
  end

  context "deleting a project" do
    let!(:project2) { create(:project, feature: current_feature) }

    before do
      visit current_path
    end

    it "deletes a project" do
      within find("tr", text: translated(project2.title)) do
        find("a.action-icon--remove").click
      end

      within ".callout-wrapper" do
        expect(page).to have_content("successfully")
      end

      within "table" do
        expect(page).to_not have_content(translated(project2.title))
      end
    end
  end
end
