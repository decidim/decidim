# frozen_string_literal: true

shared_examples "manage attachment collections examples" do
  let!(:attachment_collection) { create(:attachment_collection, collection_for:) }
  let(:attributes) { attributes_for(:attachment_collection) }

  before do
    visit current_path
  end

  it "lists all the attachment collections for the process" do
    within "#attachment_collections table" do
      expect(page).to have_content(translated(attachment_collection.name, locale: :en))
    end
  end

  it "can view an attachment collection details" do
    within "#attachment_collections table" do
      find("button[data-component='dropdown']").click
      click_on "Edit"
    end

    expect(page).to have_css("input#attachment_collection_name_en[value='#{translated(attachment_collection.name, locale: :en)}']")
    expect(page).to have_css("input#attachment_collection_weight[value='#{attachment_collection.weight}']")
    expect(page).to have_css("input#attachment_collection_description_en[value='#{translated(attachment_collection.description, locale: :en)}']")
  end

  it "can add attachment collections to a process" do
    click_on "New attachment folder"

    within ".new_attachment_collection" do
      fill_in_i18n(
        :attachment_collection_name,
        "#attachment_collection-name-tabs",
        **attributes[:name].except("machine_translations")
      )

      fill_in_i18n(
        :attachment_collection_description,
        "#attachment_collection-description-tabs",
        **attributes[:description].except("machine_translations")
      )

      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("successfully")

    within "#attachment_collections table" do
      expect(page).to have_content(translated(attributes[:name]))
    end

    visit decidim_admin.root_path
    expect(page).to have_content("created the #{translated(attributes[:name])} attachment collection")
  end

  it "can update an attachment collection" do
    within "#attachment_collections" do
      within "tr", text: translated(attachment_collection.name) do
        find("button[data-component='dropdown']").click
        click_on "Edit"
      end
    end

    within ".edit_attachment_collection" do
      fill_in_i18n(
        :attachment_collection_name,
        "#attachment_collection-name-tabs",
        **attributes[:name].except("machine_translations")
      )

      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("successfully")

    within "#attachment_collections table" do
      expect(page).to have_content(translated(attributes[:name]))
    end

    visit decidim_admin.root_path
    expect(page).to have_content("updated the #{translated(attributes[:name])} attachment collection")
  end

  context "when deleting a attachment collection" do
    let!(:attachment_collection2) { create(:attachment_collection, collection_for:) }

    context "when the attachment collection has no associated content", :slow do
      before do
        visit current_path
      end

      it "can delete the attachment collection" do
        within "tr", text: translated(attachment_collection2.name) do
          find("button[data-component='dropdown']").click
          accept_confirm { click_on "Delete" }
        end

        expect(page).to have_admin_callout("successfully")

        within "#attachment_collections table" do
          expect(page).to have_no_content(translated(attachment_collection2.name))
        end
      end
    end

    context "when the attachment collection has associated content" do
      let!(:attachment) { create(:attachment, attached_to: collection_for, attachment_collection:) }

      before do
        visit current_path
      end

      it "cannot delete it" do
        within "tr", text: translated(attachment_collection.name) do
          expect(page).to have_no_css("a.action-icon--remove")
        end
      end
    end
  end
end
