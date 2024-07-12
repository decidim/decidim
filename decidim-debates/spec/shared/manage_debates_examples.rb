# frozen_string_literal: true

RSpec.shared_examples "manage debates" do
  let!(:debate) { create :debate, category: category, component: current_component }
  let(:attributes) { attributes_for(:debate, :closed, component: current_component) }

  before { visit_component_admin }

  describe "listing" do
    context "with enriched content" do
      before do
        debate.update!(title: { en: "Debate <strong>title</strong>" })
        visit current_path
      end

      it "displays the correct title" do
        expect(page.html).to include("Debate &lt;strong&gt;title&lt;/strong&gt;")
      end
    end
  end

  describe "admin form" do
    before { click_on "New Debate" }

    it_behaves_like "having a rich text editor", "new_debate", "full"
  end

  describe "updating a debate" do
    it "updates a debate", versioning: true do
      within find("tr", text: translated(debate.title)) do
        page.find(".action-icon--edit").click
      end

      within ".edit_debate" do
        fill_in_i18n(:debate_title, "#debate-title-tabs", **attributes[:title].except("machine_translations"))
        fill_in_i18n_editor(:debate_description, "#debate-description-tabs", **attributes[:description].except("machine_translations"))
        fill_in_i18n_editor(:debate_instructions, "#debate-instructions-tabs", **attributes[:instructions].except("machine_translations"))

        find("*[type=submit]").click
      end

      within ".callout-wrapper" do
        expect(page).to have_content("successfully")
      end

      within "table" do
        expect(page).to have_content(translated(attributes[:title]))
      end

      visit decidim_admin.root_path
      expect(page).to have_content("updated the #{translated(attributes[:title])} debate on the")
    end

    context "when the debate has an author" do
      let!(:debate) { create(:debate, :participant_author, component: current_component) }

      it "cannot edit the debate" do
        within find("tr", text: translated(debate.title)) do
          expect(page).to have_no_selector(".action-icon--edit")
        end
      end
    end
  end

  describe "previewing debates" do
    it "links the debate correctly" do
      link = find("a", text: translated(debate.title))
      expect(link[:href]).to include(resource_locator(debate).path)
    end

    it "shows a preview of the debate" do
      visit resource_locator(debate).path
      expect(page).to have_content(translated(debate.title))
    end
  end

  it "creates a new finite debate", versioning: true do
    within ".card-title" do
      click_link "New Debate"
    end

    within ".new_debate" do
      fill_in_i18n(:debate_title, "#debate-title-tabs", **attributes[:title].except("machine_translations"))
      fill_in_i18n_editor(:debate_description, "#debate-description-tabs", **attributes[:description].except("machine_translations"))
      fill_in_i18n_editor(:debate_instructions, "#debate-instructions-tabs", **attributes[:instructions].except("machine_translations"))

      choose "Finite"
    end

    page.execute_script("$('#debate_start_time').focus()")
    page.find(".datepicker-dropdown .day:not(.new)", text: "12").click
    page.find(".datepicker-dropdown .hour", text: "10:00").click
    page.find(".datepicker-dropdown .minute", text: "10:50").click

    page.execute_script("$('#debate_end_time').focus()")
    page.find(".datepicker-dropdown .day:not(.new)", text: "12").click
    page.find(".datepicker-dropdown .hour", text: "12:00").click
    page.find(".datepicker-dropdown .minute", text: "12:50").click

    within ".new_debate" do
      select translated(category.name), from: :debate_decidim_category_id

      find("*[type=submit]").click
    end

    within ".callout-wrapper" do
      expect(page).to have_content("successfully")
    end

    within "table" do
      expect(page).to have_content(translated(attributes[:title]))
    end

    visit decidim_admin.root_path
    expect(page).to have_content("created the #{translated(attributes[:title])} debate on the")
  end

  it "creates a new open debate" do
    within ".card-title" do
      click_link "New Debate"
    end

    within ".new_debate" do
      fill_in_i18n(:debate_title, "#debate-title-tabs", **attributes[:title].except("machine_translations"))
      fill_in_i18n_editor(:debate_description, "#debate-description-tabs", **attributes[:description].except("machine_translations"))
      fill_in_i18n_editor(:debate_instructions, "#debate-instructions-tabs", **attributes[:instructions].except("machine_translations"))

      choose "Open"
    end

    expect(page).not_to have_selector "#debate_start_time"
    expect(page).not_to have_selector "#debate_end_time"

    within ".new_debate" do
      select translated(category.name), from: :debate_decidim_category_id

      find("*[type=submit]").click
    end

    within ".callout-wrapper" do
      expect(page).to have_content("successfully")
    end

    within "table" do
      expect(page).to have_content(translated(attributes[:title]))
    end

    visit decidim_admin.root_path
    expect(page).to have_content("created the #{translated(attributes[:title])} debate on the")
  end

  describe "deleting a debate" do
    let!(:debate2) { create(:debate, component: current_component) }

    before do
      visit current_path
    end

    it "deletes a debate" do
      within find("tr", text: translated(debate2.title)) do
        accept_confirm do
          page.find(".action-icon--remove").click
        end
      end

      within ".callout-wrapper" do
        expect(page).to have_content("successfully")
      end

      within "table" do
        expect(page).not_to have_content(translated(debate2.title))
      end
    end

    context "when the debate has an author" do
      let!(:debate2) { create(:debate, :participant_author, component: current_component) }

      it "cannot delete the debate" do
        within find("tr", text: translated(debate2.title)) do
          expect(page).to have_no_selector(".action-icon--remove")
        end
      end
    end
  end

  describe "closing a debate", versioning: true do
    it "closes a debate" do
      within find("tr", text: translated(debate.title)) do
        page.find(".action-icon--close").click
      end

      within ".edit_close_debate" do
        fill_in_i18n_editor(:debate_conclusions, "#debate-conclusions-tabs", **attributes[:conclusions].except("machine_translations"))

        find("*[type=submit]").click
      end

      within ".callout-wrapper" do
        expect(page).to have_content("successfully")
      end

      within "table" do
        within find("tr", text: translated(debate.title)) do
          expect(page).to have_no_selector(".action-icon--edit")
          page.find(".action-icon--close").click
        end
      end

      expect(page).to have_content(strip_tags(translated(attributes[:conclusions])).strip)

      visit decidim_admin.root_path
      expect(page).to have_content("performed some action on #{translated(debate.title)} in")
    end

    context "when the debate has an author" do
      let!(:debate) { create(:debate, :participant_author, component: current_component) }

      it "cannot close the debate" do
        within find("tr", text: translated(debate.title)) do
          expect(page).to have_no_selector(".action-icon--close")
        end
      end
    end
  end
end
