# frozen_string_literal: true

require "spec_helper"
describe "Admin filters meetings" do
  include_context "with filterable context"

  let(:manifest_name) { "meetings" }
  let(:model_name) { Decidim::Meetings::Meeting.model_name }
  let(:resource_controller) { Decidim::Meetings::Admin::MeetingsController }
  let!(:meeting) { create(:meeting, scope:, component:) }

  include_context "when managing a component as an admin"
  it_behaves_like "access component permissions form"

  it_behaves_like "access permissions form" do
    let!(:row_text) { translated(meeting.title) }
  end

  TYPES = Decidim::Meetings::Meeting::TYPE_OF_MEETING.keys

  def create_meeting_with_trait(trait)
    create(:meeting, trait, component:)
  end

  def meeting_with_type(type)
    Decidim::Meetings::Meeting.where(component:).find_by(type_of_meeting: type)
  end

  def meeting_without_type(type)
    Decidim::Meetings::Meeting.where(component:).where.not(type_of_meeting: type).sample
  end

  context "when filtering by type" do
    let!(:meetings) do
      TYPES.map { |state| create_meeting_with_trait(state) }
    end

    before { visit_component_admin }

    TYPES.each do |state|
      context "when filtering meetings by type: #{I18n.t(state, scope: "decidim.admin.filters.meetings.with_any_type.values")}" do
        it_behaves_like "a filtered collection", options: "Type", filter: I18n.t(state, scope: "decidim.admin.filters.meetings.with_any_type.values") do
          let(:in_filter) { translated(meeting_with_type(state).title) }
          let(:not_in_filter) { translated(meeting_without_type(state).title) }
        end
      end
    end
  end

  it_behaves_like "a collection filtered by taxonomies" do
    let!(:meeting_with_taxonomy11) { create(:meeting, component:, taxonomies: [taxonomy11]) }
    let!(:meeting_with_taxonomy12) { create(:meeting, component:, taxonomies: [taxonomy12]) }
    let!(:meeting_with_taxonomy21) { create(:meeting, component:, taxonomies: [taxonomy21]) }
    let!(:meeting_with_taxonomy22) { create(:meeting, component:, taxonomies: [taxonomy22]) }
    let(:resource_with_taxonomy11_title) { translated(meeting_with_taxonomy11.title) }
    let(:resource_with_taxonomy12_title) { translated(meeting_with_taxonomy12.title) }
    let(:resource_with_taxonomy21_title) { translated(meeting_with_taxonomy21.title) }
    let(:resource_with_taxonomy22_title) { translated(meeting_with_taxonomy22.title) }
  end

  context "when filtering by origin" do
    let!(:official_meeting) { create(:meeting, :official, component:) }
    let!(:participant_meeting) { create(:meeting, :not_official, component:) }

    before { visit_component_admin }

    context "when filtering participants" do
      context "when no official meeting is present" do
        it_behaves_like "a filtered collection", options: "Origin", filter: "Participant" do
          let(:in_filter) { translated(participant_meeting.title) }
          let(:not_in_filter) { translated(official_meeting.title) }
        end
      end
    end

    context "when filtering official" do
      context "when no participant meeting is present" do
        it_behaves_like "a filtered collection", options: "Origin", filter: "Official" do
          let(:in_filter) { translated(official_meeting.title) }
          let(:not_in_filter) { translated(participant_meeting.title) }
        end
      end
    end
  end

  context "when filtering by Date" do
    let!(:past_meeting) { create(:meeting, :past, component:) }
    let!(:future_meeting) { create(:meeting, :upcoming, component:) }

    before { visit_component_admin }

    it_behaves_like "a filtered collection", options: "Date", filter: "Upcoming" do
      let(:in_filter) { translated(future_meeting.title) }
      let(:not_in_filter) { translated(past_meeting.title) }
    end

    it_behaves_like "a filtered collection", options: "Date", filter: "Past" do
      let(:in_filter) { translated(past_meeting.title) }
      let(:not_in_filter) { translated(future_meeting.title) }
    end
  end

  context "when searching by title" do
    let!(:meeting1) { create(:meeting, component:) }
    let!(:meeting2) { create(:meeting, component:) }
    let!(:meeting1_title) { translated(meeting1.title) }
    let!(:meeting2_title) { translated(meeting2.title) }

    before { visit_component_admin }

    it "can be searched by title" do
      search_by_text(meeting2_title)

      expect(page).to have_text(meeting2_title)
    end
  end

  context "when sorting by closed" do
    let!(:open_a) { create(:meeting, component:, title: { en: "Open A" }) }
    let!(:closed_b) { create(:meeting, :closed, component:, title: { en: "Closed B" }) }
    let!(:open_c) { create(:meeting, component:, title: { en: "Open C" }) }
    let!(:closed_d) { create(:meeting, :closed, component:, title: { en: "Closed D" }) }

    before { visit_component_admin }

    it "groups closed meetings first when 'Closed' is clicked" do
      within "table thead" do
        click_on "Closed"
      end

      titles = page.all("table tbody tr td:first-child").map(&:text)
      closed_indices = [closed_b, closed_d].map { |m| titles.find_index { |t| t.include?(translated(m.title)) } }
      open_indices = [open_a, open_c].map { |m| titles.find_index { |t| t.include?(translated(m.title)) } }
      expect(closed_indices.max).to be < open_indices.min
    end
  end

  context "when sorting by taxonomies" do
    let(:root_taxonomy) { create(:taxonomy, organization:, name: { "en" => "Root" }) }
    let!(:taxonomy_alpha) { create(:taxonomy, parent: root_taxonomy, organization:, name: { "en" => "Alpha topic" }) }
    let!(:taxonomy_beta) { create(:taxonomy, parent: root_taxonomy, organization:, name: { "en" => "Beta topic" }) }
    let!(:taxonomy_gamma) { create(:taxonomy, parent: root_taxonomy, organization:, name: { "en" => "Gamma topic" }) }
    let(:taxonomy_filter) { create(:taxonomy_filter, root_taxonomy:, participatory_space_manifests: [participatory_space.manifest.name]) }
    let!(:filter_item_alpha) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: taxonomy_alpha) }
    let!(:filter_item_beta) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: taxonomy_beta) }
    let!(:filter_item_gamma) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: taxonomy_gamma) }
    let!(:meeting_beta) { create(:meeting, component:, title: { en: "Has beta" }, taxonomies: [taxonomy_beta]) }
    let!(:meeting_alpha) { create(:meeting, component:, title: { en: "Has alpha" }, taxonomies: [taxonomy_alpha]) }
    let!(:meeting_gamma) { create(:meeting, component:, title: { en: "Has gamma" }, taxonomies: [taxonomy_gamma]) }

    before do
      component.update!(settings: { taxonomy_filters: [taxonomy_filter.id] })
      visit_component_admin
    end

    it "sorts by taxonomy name ascending when 'Taxonomies' is clicked" do
      within "table thead" do
        click_on "Taxonomies"
      end

      titles = page.all("table tbody tr td:first-child").map(&:text)
      expect(titles.find_index { |t| t.include?("Has alpha") }).to be < titles.find_index { |t| t.include?("Has beta") }
      expect(titles.find_index { |t| t.include?("Has beta") }).to be < titles.find_index { |t| t.include?("Has gamma") }
    end
  end

  context "when sorting by title" do
    let!(:beta_meeting) { create(:meeting, component:, title: { en: "Beta meeting" }) }
    let!(:alpha_meeting) { create(:meeting, component:, title: { en: "Alpha meeting" }) }
    let!(:gamma_meeting) { create(:meeting, component:, title: { en: "Gamma meeting" }) }

    before { visit_component_admin }

    it "sorts by title descending when 'Title' is clicked" do
      within "table thead" do
        click_on "Title"
      end

      titles = page.all("table tbody tr td:first-child").map(&:text)
      expect(titles.index("Gamma meeting")).to be < titles.index("Beta meeting")
      expect(titles.index("Beta meeting")).to be < titles.index("Alpha meeting")
    end

    it "sorts by title ascending when 'Title' is clicked twice" do
      within "table thead" do
        click_on "Title"
        click_on "Title"
      end

      titles = page.all("table tbody tr td:first-child").map(&:text)
      expect(titles.index("Alpha meeting")).to be < titles.index("Beta meeting")
      expect(titles.index("Beta meeting")).to be < titles.index("Gamma meeting")
    end
  end

  it_behaves_like "paginating a collection" do
    let!(:collection) { create_list(:meeting, 50, component:) }
  end
end
