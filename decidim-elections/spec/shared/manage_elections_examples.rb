# frozen_string_literal: true

RSpec.shared_examples "manage elections" do
  let(:participatory_space_manifests) { [participatory_process.manifest.name] }
  let!(:election) { create(:election, component: current_component) }
  let(:attributes) { attributes_for(:election, component: current_component) }
  let(:start_time) { Time.current.change(day: 10, hour: 12, min: 50) }
  let(:end_time) { Time.current.change(day: 12, hour: 12, min: 50) }

  before do
    visit_component_admin
  end

  it "creates a new election with manual start" do
    click_on "New election"

    within ".new_election" do
      fill_in_i18n(:election_title, "#election-title-tabs", **attributes[:title].except("machine_translations"))
      fill_in_i18n_editor(:election_description, "#election-description-tabs", **attributes[:description].except("machine_translations"))
      fill_in_datepicker :election_end_at_date, with: end_time.strftime("%d/%m/%Y")
      fill_in_timepicker :election_end_at_time, with: end_time.strftime("%H:%M")
      check "Manual start"
      choose "Real time"
    end

    click_on "Save and continue"

    expect(page).to have_admin_callout "Election created successfully"
    expect(page).to have_content("Question must have at least two answers in order go to the next step.")

    visit decidim_admin.root_path
    expect(page).to have_content("created the #{translated(attributes[:title])} election in")
  end

  describe "admin form" do
    before { click_on "New election" }

    it_behaves_like "having a rich text editor", "new_election", "full"
  end

  describe "updating an election" do
    it "updates an election" do
      within "tr", text: translated(election.title) do
        find("button[data-component='dropdown']").click
        click_on "Edit election"
      end

      within ".edit_election" do
        uncheck "Manual start"
        fill_in_datepicker :election_start_at_date, with: start_time.strftime("%d/%m/%Y")
        fill_in_timepicker :election_start_at_time, with: start_time.strftime("%H:%M")
      end

      click_on "Save and continue"

      expect(page).to have_admin_callout "Election updated successfully"
      # redirect to questions tab
    end
  end
end
