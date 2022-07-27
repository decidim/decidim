# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Meeting directory search", type: :request do
  include Decidim::ComponentPathHelper

  subject { response.body }

  let(:organization) { create(:organization) }
  let!(:components) { create_list(:component, 3, manifest_name: "meetings", organization:) }
  let(:user) { create :user, :confirmed, organization: }

  let(:participatory_space) { components.first.participatory_space }
  let!(:category1) { create :category, participatory_space: }
  let!(:category2) { create :category, participatory_space: }
  let!(:child_category) { create :category, participatory_space:, parent: category2 }
  let!(:meeting1) { create(:meeting, :published, component: components.second) }
  let!(:meeting2) { create(:meeting, :published, component: components.first, category: category1) }
  let!(:meeting3) { create(:meeting, :published, component: components.first, category: category2) }
  let!(:meeting4) { create(:meeting, :published, component: components.first, category: child_category) }
  let!(:meeting5) { create(:meeting, :published, component: components.third) }

  let(:filter_params) { {} }
  let(:request_path) { engine_routes.meetings_path }
  let(:engine_routes) { Decidim::Meetings::DirectoryEngine.routes.url_helpers }

  before do
    get(
      request_path,
      params: { filter: filter_params },
      headers: { "HOST" => organization.host }
    )
  end

  it "displays all meetings without any filters" do
    expect(subject).to include(translated(meeting1.title))
    expect(subject).to include(translated(meeting2.title))
    expect(subject).to include(translated(meeting3.title))
    expect(subject).to include(translated(meeting4.title))
    expect(subject).to include(translated(meeting5.title))
  end

  context "when filtering by category" do
    let(:filter_params) { { with_any_global_category: category_ids } }

    context "and no category filter is present" do
      let(:category_ids) { nil }

      it "displays all resources" do
        expect(subject).to include(translated(meeting1.title))
        expect(subject).to include(translated(meeting2.title))
        expect(subject).to include(translated(meeting3.title))
        expect(subject).to include(translated(meeting4.title))
        expect(subject).to include(translated(meeting5.title))
      end
    end

    context "and a category is selected" do
      let(:category_ids) { [category2.id] }

      it "displays only resources for that category and its children" do
        expect(subject).not_to include(translated(meeting1.title))
        expect(subject).not_to include(translated(meeting2.title))
        expect(subject).to include(translated(meeting3.title))
        expect(subject).to include(translated(meeting4.title))
        expect(subject).not_to include(translated(meeting5.title))
      end
    end

    context "and a subcategory is selected" do
      let(:category_ids) { [child_category.id] }

      it "displays only resources for that category" do
        expect(subject).not_to include(translated(meeting1.title))
        expect(subject).not_to include(translated(meeting2.title))
        expect(subject).not_to include(translated(meeting3.title))
        expect(subject).to include(translated(meeting4.title))
        expect(subject).not_to include(translated(meeting5.title))
      end
    end

    context "and a participatory process is selected" do
      let(:value) { participatory_space.class.name.gsub("::", "__") + participatory_space.id.to_s }
      let(:category_ids) { [value] }

      it "displays only resources for that participatory_process - all categories and sub-categories" do
        expect(subject).not_to include(translated(meeting1.title))
        expect(subject).to include(translated(meeting2.title))
        expect(subject).to include(translated(meeting3.title))
        expect(subject).to include(translated(meeting4.title))
        expect(subject).not_to include(translated(meeting5.title))
      end
    end

    context "and the provided category is `without`" do
      let(:category_ids) { ["without"] }

      it "returns resources without a category" do
        expect(subject).to include(translated(meeting1.title))
        expect(subject).not_to include(translated(meeting2.title))
        expect(subject).not_to include(translated(meeting3.title))
        expect(subject).not_to include(translated(meeting4.title))
        expect(subject).to include(translated(meeting5.title))
      end
    end

    context "and the provided category is `without` or some category id" do
      let(:category_ids) { ["without", category1.id] }

      it "returns resources without a category and with the selected category" do
        expect(subject).to include(translated(meeting1.title))
        expect(subject).to include(translated(meeting2.title))
        expect(subject).not_to include(translated(meeting3.title))
        expect(subject).not_to include(translated(meeting4.title))
        expect(subject).to include(translated(meeting5.title))
      end
    end
  end
end
