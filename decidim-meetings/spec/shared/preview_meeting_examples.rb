require "spec_helper"
require "decidim/dev/test/rspec_support/tom_select"

shared_examples "process admin manages meetings", serves_geocoding_autocomplete: true, serves_map: true do
  let(:manifest_name) { "meetings" }
  let!(:meeting) { create(:meeting, :published, services: [], component: current_component, start_time: base_date + 1.day, end_time: base_date + 26.hours) }
  let(:address) { "Some address" }
  let(:latitude) { 40.1234 }
  let(:longitude) { 2.1234 }
  let(:service_titles) { ["This is the first service", "This is the second service"] }
  let(:base_date) { Time.zone.now.change(usec: 0) }
  let(:meeting_start_date) { base_date.strftime("%d/%m/%Y") }
  let(:meeting_start_time) { base_date.utc.strftime("%H:%M") }
  let(:meeting_end_date) { ((base_date + 2.days) + 1.month).strftime("%d/%m/%Y") }
  let(:meeting_end_time) { (base_date + 4.hours).strftime("%H:%M") }
  let(:attributes) { attributes_for(:meeting, component: current_component, skip_injection: true) }
  let(:root_taxonomy) { create(:taxonomy, organization:) }
  let!(:taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:) }
  let(:taxonomy_filter) { create(:taxonomy_filter, root_taxonomy:) }
  let!(:taxonomy_filter_item) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: taxonomy) }
  let(:taxonomy_filter_ids) { [taxonomy_filter.id] }
  let!(:follow) { create(:follow, followable: meeting, user:) }

  include_context "when managing a component as an admin" do
    let(:participatory_process) { create(:participatory_process, :published, :with_steps, organization:) }
    let!(:component) { create(:component, :published, manifest:, participatory_space:) }
  end

  before do
    stub_geocoding(address, [latitude, longitude])
    component.update!(settings: { taxonomy_filters: taxonomy_filter_ids })
  end

  it "allows the user to preview an unpublished meeting" do
    unpublished_meeting = create(:meeting, services: [], component: current_component)
    visit current_path

    meeting_path = resource_locator(unpublished_meeting).path

    within "tr", text: Decidim::Meetings::MeetingPresenter.new(unpublished_meeting).title do
      klass = "action-icon--preview"

      expect(page).to have_xpath(
        "//a[contains(@class,'#{klass}')][@href='#{meeting_path}'][@target='blank']"
      )
    end

    # Visit the unpublished meeting
    page.visit meeting_path

    expect(page).to have_current_path(meeting_path)
  end
end
