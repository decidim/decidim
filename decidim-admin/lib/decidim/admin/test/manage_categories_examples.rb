# frozen_string_literal: true

shared_examples "manage categories examples" do
  it "lists all the categories for the process" do
    within "#categories table" do
      expect(page).to have_content(translated(category.name, locale: :en))
    end
  end

  it "can view a category detail" do
    within "#categories table" do
      click_link translated(category.name, locale: :en)
    end

    expect(page).to have_selector("input#category_name_en[value='#{translated(category.name, locale: :en)}']")
    expect(page).to have_selector("input#category_weight[value='#{category.weight}']")

    expect(page).to have_selector("select#category_parent_id")
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

  context "when deleting a category" do
    let!(:category2) { create(:category, participatory_space:) }

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
            expect(page).to have_no_content(translated(category2.name))
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

          expect(page).to have_admin_callout("problem deleting")

          within "#categories table" do
            expect(page).to have_content(translated(category2.name))
          end
        end
      end
    end

    context "when the category has associated content" do
      let!(:component) { create(:component, participatory_space:) }
      let!(:dummy_resource) { create(:dummy_resource, component:, category:) }

      it "cannot delete it" do
        visit current_path

        within find("tr", text: translated(category.name)) do
          expect(page).to have_no_selector("a.action-icon--remove")
        end
      end
    end
  end
end
