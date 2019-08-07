# frozen_string_literal: true

shared_examples "manage projects" do
  it "updates a project" do
    within find("tr", text: translated(project.title)) do
      click_link "Edit"
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

    expect(page).to have_admin_callout("successfully")

    within "table" do
      expect(page).to have_content("My new title")
    end
  end

  context "when previewing projects" do
    it "allows the user to preview the project" do
      within find("tr", text: translated(project.title)) do
        klass = "action-icon--preview"
        href = resource_locator(project).path
        target = "blank"

        expect(page).to have_selector(
          :xpath,
          "//a[contains(@class,'#{klass}')][@href='#{href}'][@target='#{target}']"
        )
      end
    end
  end

  context "when seeing finished and pending votes" do
    let!(:project) { create(:project, budget: 70_000_000, component: current_component) }

    let!(:finished_orders) do
      orders = create_list(:order, 10, component: current_component)
      orders.each do |order|
        order.update!(line_items: [create(:line_item, project: project, order: order)])
        order.reload
        order.update!(checked_out_at: Time.zone.today)
      end
    end

    let!(:pending_orders) do
      create_list(:order, 5, component: current_component, checked_out_at: nil)
    end

    it "shows the order count" do
      visit current_path
      expect(page).to have_content("Finished votes: \n10")
      expect(page).to have_content("Pending votes: \n5")
    end
  end

  it "creates a new project", :slow do
    find(".card-title a.button.new").click

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

      scope_pick select_data_picker(:project_decidim_scope_id), scope
      select translated(category.name), from: :project_decidim_category_id

      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("successfully")

    within "table" do
      expect(page).to have_content("My project")
    end
  end

  context "when deleting a project" do
    let!(:project2) { create(:project, component: current_component) }

    before do
      visit current_path
    end

    it "deletes a project" do
      within find("tr", text: translated(project2.title)) do
        accept_confirm { click_link "Delete" }
      end

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).to have_no_content(translated(project2.title))
      end
    end
  end
end
