# frozen_string_literal: true

shared_examples "manage attachment collections examples" do
  let!(:attachment_collection) { create(:attachment_collection, collection_for:) }

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
      click_link translated(attachment_collection.name, locale: :en)
    end

    expect(page).to have_selector("input#attachment_collection_name_en[value='#{translated(attachment_collection.name, locale: :en)}']")
    expect(page).to have_selector("input#attachment_collection_weight[value='#{attachment_collection.weight}']")
    expect(page).to have_selector("input#attachment_collection_description_en[value='#{translated(attachment_collection.description, locale: :en)}']")
  end

  it "can add attachment collections to a process" do
    find(".card-title a.new").click

    within ".new_attachment_collection" do
      fill_in_i18n(
        :attachment_collection_name,
        "#attachment_collection-name-tabs",
        en: "Application forms",
        es: "Formularios de solicitud",
        ca: "Formularis de sol·licitud"
      )

      fill_in_i18n(
        :attachment_collection_description,
        "#attachment_collection-description-tabs",
        en: "Contains the application forms",
        es: "Contiene los formularios de solicitud",
        ca: "Conté els formularis de sol·licitud"
      )

      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("successfully")

    within "#attachment_collections table" do
      expect(page).to have_link("Application forms")
    end
  end

  it "can update an attachment collection" do
    within "#attachment_collections" do
      within find("tr", text: translated(attachment_collection.name)) do
        click_link "Edit"
      end
    end

    within ".edit_attachment_collection" do
      fill_in_i18n(
        :attachment_collection_name,
        "#attachment_collection-name-tabs",
        en: "Latest application forms",
        es: "Últimos formularios de solicitud",
        ca: "Últims formularis de sol·licitud"
      )

      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("successfully")

    within "#attachment_collections table" do
      expect(page).to have_link("Latest application forms")
    end
  end

  context "when deleting a attachment collection" do
    let!(:attachment_collection2) { create(:attachment_collection, collection_for:) }

    context "when the attachment collection has no associated content", :slow do
      before do
        visit current_path
      end

      it "can delete the attachment collection" do
        within find("tr", text: translated(attachment_collection2.name)) do
          accept_confirm { click_link "Delete" }
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
        within find("tr", text: translated(attachment_collection.name)) do
          expect(page).to have_no_selector("a.action-icon--remove")
        end
      end
    end
  end
end
