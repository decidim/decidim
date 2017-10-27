# frozen_string_literal: true

shared_examples "manage projects" do
  it "updates a project" do
    within find("tr", text: translated(project.title)) do
      find("a.action-icon--edit").click
    end

    within ".edit_project" do
      fill_in_i18n(
        :project_title,
        "#project-title-tabs",
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

  context "previewing projects", driver: :poltergeist do
    it "allows the user to preview the project" do
      within find("tr", text: translated(project.title)) do
        @new_window = window_opened_by { find("a.action-icon--preview").click }
      end

      within_window @new_window do
        expect(current_path).to eq resource_locator(project).path
        expect(page).to have_content(translated(project.title))
      end
    end
  end

  context "seeing finished and pending votes" do
    let!(:project) { create(:project, budget: 70_000_000, feature: current_feature) }

    let!(:finished_orders) do
      orders = create_list(:order, 10, feature: current_feature)
      orders.each do |order|
        order.update_attributes!(line_items: [create(:line_item, project: project, order: order)])
        order.reload
        order.update_attributes!(checked_out_at: Time.zone.today)
      end
    end

    let!(:pending_orders) do
      create_list(:order, 5, feature: current_feature, checked_out_at: nil)
    end

    it "shows the order count" do
      visit current_path
      expect(page).to have_content("Finished votes: 10")
      expect(page).to have_content("Pending votes: 5")
    end
  end

  it "creates a new project" do
    find(".card-title a.button").click

    within ".new_project" do
      fill_in_i18n(
        :project_title,
        "#project-title-tabs",
        en: "My project",
        es: "Mi proyecto",
        ca: "El meu projecte"
      )
      fill_in_i18n_editor(
        :project_description,
        "#project-description-tabs",
        en: "A longer description",
        es: "Descripción más larga",
        ca: "Descripció més llarga"
      )
      fill_in :project_budget, with: 22_000_000

      select2 translated(scope.name), xpath: '//select[@id="project_decidim_scope_id"]/..', search: true
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
        accept_confirm { find("a.action-icon--remove").click }
      end

      within ".callout-wrapper" do
        expect(page).to have_content("successfully")
      end

      within "table" do
        expect(page).to have_no_content(translated(project2.title))
      end
    end
  end
end
