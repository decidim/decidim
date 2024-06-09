# frozen_string_literal: true

shared_examples "manage categories examples" do
  let(:attributes) { attributes_for(:category) }
  it "lists all the categories for the process" do
    within "#categories table" do
      expect(page).to have_content(translated(category.name, locale: :en))
    end
  end

  it "can view a category detail" do
    within "#categories table" do
      click_on translated(category.name, locale: :en)
    end

    expect(page).to have_css("input#category_name_en[value='#{translated(category.name, locale: :en)}']")
    expect(page).to have_css("input#category_weight[value='#{category.weight}']")

    expect(page).to have_select(id: "category_parent_id")
  end

  it "creates a new category" do
    click_on "New category"

    within ".new_category" do
      fill_in_i18n(
        :category_name,
        "#category-name-tabs",
        **attributes[:name].except("machine_translations")
      )

      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("successfully")

    within "#categories table" do
      expect(page).to have_content(translated(attributes[:name]))
    end
    visit decidim_admin.root_path
    expect(page).to have_content("added the #{translated(attributes[:name])} category to the")
  end

  it "updates a category" do
    within "#categories" do
      within "tr", text: translated(category.name) do
        click_on "Edit"
      end
    end

    within ".edit_category" do
      fill_in_i18n(
        :category_name,
        "#category-name-tabs",
        **attributes[:name].except("machine_translations")
      )

      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("successfully")

    within "#categories table" do
      expect(page).to have_content(translated(attributes[:name]))
    end
    visit decidim_admin.root_path
    expect(page).to have_content("updated the #{translated(attributes[:name])} category in the")
  end

  context "when deleting a category" do
    let!(:category2) { create(:category, participatory_space:) }

    context "when the category has no associated content" do
      context "when the category has no subcategories" do
        before do
          visit current_path
        end

        it "deletes a category" do
          within "tr", text: translated(category2.name) do
            accept_confirm { click_on "Delete" }
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
          within "tr", text: translated(category2.name) do
            accept_confirm { click_on "Delete" }
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

        within "tr", text: translated(category.name) do
          expect(page).to have_no_css("a.action-icon--remove")
        end
      end
    end
  end
end
