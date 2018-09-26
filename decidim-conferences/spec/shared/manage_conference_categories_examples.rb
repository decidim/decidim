# frozen_string_literal: true

shared_examples "manage conference categories" do
  let!(:category) do
    create(
      :category,
      participatory_space: conference
    )
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_conferences.edit_conference_path(conference)
    click_link "Categories"
  end

  it "creates a new category" do
    find(".card-title a.new").click

    within ".new_category" do
      fill_in_i18n(
        :category_name,
        "#category-name-tabs",
        en: "My category",
        es: "Mi categoría",
        ca: "La meva categoria"
      )
      fill_in_i18n_editor(
        :category_description,
        "#category-description-tabs",
        en: "Description",
        es: "Descripción",
        ca: "Descripció"
      )

      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("successfully")

    within "#categories table" do
      expect(page).to have_content("My category")
    end
  end

  it "updates a category" do
    within "#categories" do
      within find("tr", text: translated(category.name)) do
        click_link "Edit"
      end
    end

    within ".edit_category" do
      fill_in_i18n(
        :category_name,
        "#category-name-tabs",
        en: "My new name",
        es: "Mi nuevo nombre",
        ca: "El meu nou nom"
      )

      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("successfully")

    within "#categories table" do
      expect(page).to have_content("My new name")
    end
  end

  describe "deleting a category" do
    let!(:category2) { create(:category, participatory_space: conference) }

    context "when the category has no associated content" do
      context "when the category has no subcategories" do
        before do
          visit current_path
        end

        it "deletes a category" do
          within find("tr", text: translated(category2.name)) do
            accept_confirm { click_link "Delete" }
          end

          expect(page).to have_admin_callout("successfully")

          within "#categories table" do
            expect(page).not_to have_content(translated(category2.name))
          end
        end
      end

      context "when the category has some subcategories" do
        let!(:subcategory) { create(:subcategory, parent: category2) }

        before do
          visit current_path
        end

        it "deletes a category" do
          within find("tr", text: translated(category2.name)) do
            accept_confirm { click_link "Delete" }
          end

          expect(page).to have_admin_callout("error deleting")

          within "#categories table" do
            expect(page).to have_content(translated(category2.name))
          end
        end
      end
    end

    context "when the category has associated content" do
      let!(:component) { create(:component, participatory_space: conference) }
      let!(:dummy_resource) { create(:dummy_resource, component: component, category: category) }

      it "cannot delete it" do
        visit current_path

        within find("tr", text: translated(category.name)) do
          expect(page).not_to have_selector("a.action-icon--remove")
        end
      end
    end
  end
end
