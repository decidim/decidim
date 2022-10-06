# frozen_string_literal: true

shared_examples "manage agenda" do
  context "when agenda is created" do
    let!(:agenda) { create :agenda, meeting: }
    let!(:agenda_items) { create_list(:agenda_item, 2, agenda:, duration: 15) }

    it "updates the agenda" do
      visit_agenda_form

      within ".edit_agenda" do
        fill_in_i18n(
          :meeting_agenda_title,
          "#meeting_agenda-title-tabs",
          en: "My edited agenda",
          es: "Mi agenda editada",
          ca: "La meva agenda editada"
        )

        within page.find(".meeting-agenda-item", match: :first) do
          fill_in find_nested_form_field_locator("title_en"), with: "My edited agenda item"
        end

        click_button "Update"
      end

      expect(page).to have_admin_callout("Agenda successfully updated")

      visit_agenda_form

      expect(page).to have_selector("input[value='My edited agenda']")
      expect(page).to have_selector("input[value='My edited agenda item']")
    end
  end

  context "when agenda is not created" do
    let(:agenda_items) do
      [
        { title: "This is the first agenda item", duration: 15 },
        { title: "This is the second agenda item", duration: 30 }
      ]
    end

    it "creates the agenda" do
      visit_agenda_form

      within ".new_agenda" do
        fill_in_i18n(
          :meeting_agenda_title,
          "#meeting_agenda-title-tabs",
          en: "My agenda",
          es: "Mi agenda",
          ca: "La meva agenda"
        )

        2.times { click_button "Add agenda item" }

        expect(page).to have_selector(".meeting-agenda-item", count: 2)

        page.all(".meeting-agenda-item").each_with_index do |agenda_item, idx|
          within agenda_item do
            fill_in find_nested_form_field_locator("title_en"), with: agenda_items[idx][:title]
            fill_in find_nested_form_field_locator("duration"), with: agenda_items[idx][:duration]
          end
        end

        click_button "Create"
      end

      expect(page).to have_admin_callout("Agenda successfully created")

      visit_agenda_form

      expect(page).to have_selector("input[value='My agenda']")
      expect(page).to have_selector("input[value='This is the first agenda item']")
      expect(page).to have_selector("input[value='This is the second agenda item']")
    end
  end

  private

  def find_nested_form_field_locator(attribute, visible: :visible)
    current_scope.find(nested_form_field_selector(attribute), visible:)["id"]
  end

  def nested_form_field_selector(attribute)
    "[id$=#{attribute}]"
  end

  def visit_agenda_form
    visit_component_admin

    within find("tr", text: translated(meeting.title)) do
      page.click_link "Agenda"
    end
  end
end
