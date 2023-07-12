# frozen_string_literal: true

shared_examples "manage projects" do
  describe "admin form" do
    before do
      within ".process-content" do
        page.find(".button--title.new").click
      end
    end

    it_behaves_like "having a rich text editor", "new_project", "full"

    it "displays the proposals picker" do
      expect(page).to have_content("Choose proposals")
    end

    context "when geocoding is enabled", :serves_geocoding_autocomplete do
      let(:address) { "Some address" }
      let(:latitude) { 40.1234 }
      let(:longitude) { 2.1234 }

      before do
        stub_geocoding(address, [latitude, longitude])
        current_component.update!(settings: { geocoding_enabled: true })
        visit current_path
      end

      it "creates a new project" do
        within ".new_project" do
          fill_in_i18n :project_title, "#project-title-tabs", en: "Make decidim great again"
          fill_in_i18n_editor :project_description, "#project-description-tabs", en: "Decidim is great but it can be better"
          fill_in :project_address, with: address
          fill_in :project_budget_amount, with: 1234
          find("*[type=submit]").click
        end

        expect(page).to have_admin_callout("successfully")

        within "table" do
          project = Decidim::Budgets::Project.last

          expect(page).to have_content("Make decidim great again")
          expect(translated(project.description)).to eq("<p>Decidim is great but it can be better</p>")
        end
      end

      it_behaves_like(
        "a record with front-end geocoding address field",
        Decidim::Budgets::Project,
        within_selector: ".new_project",
        address_field: :project_address
      ) do
        let(:geocoded_address_value) { address }
        let(:geocoded_address_coordinates) { [latitude, longitude] }

        before do
          stub_geocoding(address, [latitude, longitude])
          within ".new_project" do
            fill_in_i18n :project_title, "#project-title-tabs", en: "Make decidim great again"
            fill_in_i18n_editor :project_description, "#project-description-tabs", en: "Decidim is great but it can be better"
            fill_in :project_budget_amount, with: 1234
          end
        end
      end
    end

    context "when proposal linking is disabled" do
      before do
        allow(Decidim::Budgets).to receive(:enable_proposal_linking).and_return(false)

        # Reload the page with the updated settings
        visit current_path
      end

      it "does not display the proposal picker" do
        expect(page).not_to have_content "Choose proposals"
      end
    end
  end

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
        href = resource_locator([project.budget, project]).path
        target = "blank"

        expect(page).to have_selector(
          :xpath,
          "//a[contains(@class,'#{klass}')][@href='#{href}'][@target='#{target}']"
        )
      end
    end
  end

  context "when seeing finished and pending votes" do
    let!(:project) { create(:project, budget_amount: 70_000_000, budget:) }

    let!(:finished_orders) do
      orders = create_list(:order, 10, budget:)
      orders.each do |order|
        order.update!(line_items: [create(:line_item, project:, order:)])
        order.reload
        order.update!(checked_out_at: Time.zone.today)
      end
    end

    let!(:pending_orders) do
      create_list(:order, 5, budget:, checked_out_at: nil)
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
      fill_in :project_budget_amount, with: 22_000_000

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
    let!(:project2) { create(:project, budget:) }

    before do
      visit current_path
    end

    it "deletes a project" do
      within find("tr", text: translated(project2.title)) do
        accept_confirm(admin: true) { click_link "Delete" }
      end

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).not_to have_content(translated(project2.title))
      end
    end
  end

  context "when having existing proposals" do
    let!(:proposal_component) { create(:proposal_component, participatory_space:) }
    let!(:proposals) { create_list(:proposal, 5, component: proposal_component) }

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

        proposals_pick(select_data_picker(:project_proposals, multiple: true), proposals.last(2))

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).to have_content("My new title")
      end
    end

    it "removes proposals from project", :slow do
      project.link_resources(proposals, "included_proposals")
      not_removed_projects_title = project.linked_resources(:proposals, "included_proposals").first.title
      expect(project.linked_resources(:proposals, "included_proposals").count).to eq(5)

      within find("tr", text: translated(project.title)) do
        click_link "Edit"
      end

      within ".edit_project" do
        proposals_remove(select_data_picker(:project_proposals, multiple: true), proposals.last(4))

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
      expect(project.linked_resources(:proposals, "included_proposals").count).to eq(1)
      expect(project.linked_resources(:proposals, "included_proposals").first.title).to eq(not_removed_projects_title)
    end

    it "creates a new project", :slow do
      find(".card-title a.button.new").click

      within ".new_project" do
        fill_in_i18n(
          :project_title,
          "#project-title-tabs",
          en: "My project",
          es: "Mi project",
          ca: "El meu project"
        )
        fill_in_i18n_editor(
          :project_description,
          "#project-description-tabs",
          en: "A longer description",
          es: "Descripción más larga",
          ca: "Descripció més llarga"
        )
        fill_in :project_budget_amount, with: 22_000_000

        proposals_pick(select_data_picker(:project_proposals, multiple: true), proposals.first(2))
        scope_pick(select_data_picker(:project_decidim_scope_id), scope)
        select translated(category.name), from: :project_decidim_category_id

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).to have_content("My project")
      end
    end
  end
end
