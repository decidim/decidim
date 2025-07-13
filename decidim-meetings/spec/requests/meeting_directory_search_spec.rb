# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Meeting directory search" do
  include Decidim::ComponentPathHelper

  subject { response.body }

  let(:organization) { create(:organization) }
  let!(:components) do
    [
      create(:component, manifest_name: "meetings", participatory_space:),
      create(:component, manifest_name: "meetings", organization:),
      create(:component, manifest_name: "meetings", organization:)
    ]
  end
  let(:user) { create(:user, :confirmed, organization:) }

  let(:participatory_space) { create(:assembly, organization:) }
  let!(:taxonomy1) { create(:taxonomy, :with_parent, organization:) }
  let!(:taxonomy2) { create(:taxonomy, :with_parent, organization:) }
  let!(:child_taxonomy) { create(:taxonomy, organization:, parent: taxonomy2) }
  let(:taxonomy_filter1) { create(:taxonomy_filter, root_taxonomy: taxonomy1.parent, participatory_space_manifests: [participatory_space.manifest.name]) }
  let!(:taxonomy_filter1_item) { create(:taxonomy_filter_item, taxonomy_item: taxonomy1, taxonomy_filter: taxonomy_filter1) }
  let(:taxonomy_filter2) { create(:taxonomy_filter, root_taxonomy: taxonomy2.parent, participatory_space_manifests: [participatory_space.manifest.name]) }
  let!(:taxonomy_filter2_item) { create(:taxonomy_filter_item, taxonomy_item: taxonomy2, taxonomy_filter: taxonomy_filter2) }
  let!(:taxonomy_filter_ids) { [taxonomy_filter1.id, taxonomy_filter2.id] }
  let(:meeting1) { create(:meeting, :published, component: components.second) }
  let(:meeting2) { create(:meeting, :published, component: components.first, taxonomies: [taxonomy1]) }
  let(:meeting3) { create(:meeting, :published, component: components.first, taxonomies: [taxonomy2]) }
  let(:meeting4) { create(:meeting, :published, component: components.first, taxonomies: [child_taxonomy]) }
  let(:meeting5) { create(:meeting, :published, component: components.third) }
  let!(:meeting1_title) { decidim_escape_translated(meeting1.title) }
  let!(:meeting2_title) { decidim_escape_translated(meeting2.title) }
  let!(:meeting3_title) { decidim_escape_translated(meeting3.title) }
  let!(:meeting4_title) { decidim_escape_translated(meeting4.title) }
  let!(:meeting5_title) { decidim_escape_translated(meeting5.title) }

  let(:filter_params) { {} }
  let(:request_path) { engine_routes.meetings_path }
  let(:engine_routes) { Decidim::Meetings::DirectoryEngine.routes.url_helpers }

  before do
    components.first.update!(settings: { taxonomy_filters: taxonomy_filter_ids })
    get(
      request_path,
      params: { filter: filter_params },
      headers: { "HOST" => organization.host }
    )
  end

  it "displays all meetings without any filters" do
    expect(subject).to include(meeting1_title)
    expect(subject).to include(meeting2_title)
    expect(subject).to include(meeting3_title)
    expect(subject).to include(meeting4_title)
    expect(subject).to include(meeting5_title)
  end

  context "when filtering by taxonomy" do
    let(:filter_params) { { with_any_taxonomies: taxonomy_ids } }

    context "and no taxonomy filter is present" do
      let(:taxonomy_ids) { nil }

      it "displays all resources" do
        expect(subject).to include(meeting1_title)
        expect(subject).to include(meeting2_title)
        expect(subject).to include(meeting3_title)
        expect(subject).to include(meeting4_title)
        expect(subject).to include(meeting5_title)
      end
    end

    context "and a taxonomy is selected" do
      let(:taxonomy_ids) { { taxonomy2.parent_id => [taxonomy2.id] } }

      it "displays only resources for that taxonomy and its children" do
        expect(subject).not_to include(meeting1_title)
        expect(subject).not_to include(meeting2_title)
        expect(subject).to include(meeting3_title)
        expect(subject).to include(meeting4_title)
        expect(subject).not_to include(meeting5_title)
      end
    end

    context "and a sub taxonomy is selected" do
      let(:taxonomy_ids) { { taxonomy2.parent_id => [child_taxonomy.id] } }

      it "displays only resources for that taxonomy" do
        expect(subject).not_to include(meeting1_title)
        expect(subject).not_to include(meeting2_title)
        expect(subject).not_to include(meeting3_title)
        expect(subject).to include(meeting4_title)
        expect(subject).not_to include(meeting5_title)
      end
    end

    context "and a participatory space type is selected" do
      let(:value) { participatory_space.class.to_s.underscore }
      let(:filter_params) { { with_any_space: [value] } }

      it "displays only resources for that participatory_process - all taxonomies and sub-taxonomies" do
        expect(subject).not_to include(meeting1_title)
        expect(subject).to include(meeting2_title)
        expect(subject).to include(meeting3_title)
        expect(subject).to include(meeting4_title)
        expect(subject).not_to include(meeting5_title)
      end
    end
  end
end
