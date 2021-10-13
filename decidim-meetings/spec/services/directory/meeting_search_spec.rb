# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings::Directory
  describe MeetingSearch do
    subject { described_class.new(params).results }

    let!(:component) { create_list(:component, 3, manifest_name: "meetings") }
    let(:user) { create :user, organization: component.first.organization }
    let(:default_params) { { component: component, organization: component.first.organization, user: user } }
    let(:params) { default_params }

    describe "a resource search with categories" do
      let(:participatory_process) { component.first.participatory_space }
      let(:params) { default_params.merge(category_id: category_ids) }

      describe "results" do
        let!(:category1) { create :category, participatory_space: participatory_process }
        let!(:category2) { create :category, participatory_space: participatory_process }
        let!(:child_category) { create :category, participatory_space: participatory_process, parent: category2 }
        let!(:meeting1) { create(:meeting, :published, component: component.first) }
        let!(:meeting2) { create(:meeting, :published, component: component.first, category: category1) }
        let!(:meeting3) { create(:meeting, :published, component: component.first, category: category2) }
        let!(:meeting4) { create(:meeting, :published, component: component.first, category: child_category) }

        context "when no category filter is present" do
          let(:category_ids) { nil }

          it "includes all resources" do
            expect(subject).to match_array [meeting1, meeting2, meeting3, meeting4]
          end
        end

        context "when a category is selected" do
          let(:category_ids) { [category2.id] }

          it "includes only resources for that category and its children" do
            expect(subject).to match_array [meeting3, meeting4]
          end
        end

        context "when a participatory process is selected" do
          let(:value) { participatory_process.class.name.gsub("::", "__") + participatory_process.id.to_s }
          let(:category_ids) { [value] }

          it "includes only resources for that participatory_process - all categories and sub-categories" do
            expect(subject).to match_array [meeting2, meeting3, meeting4]
          end
        end

        context "when a subcategory is selected" do
          let(:category_ids) { [child_category.id] }

          it "includes only resources for that category" do
            expect(subject).to eq [meeting4]
          end
        end

        context "when `without` is being sent" do
          let(:category_ids) { ["without"] }

          it "returns resources without a category" do
            expect(subject).to eq [meeting1]
          end
        end

        context "when `without` and some category id is being sent" do
          let(:category_ids) { ["without", category1.id] }

          it "returns resources without a category and with the selected category" do
            expect(subject).to match_array [meeting1, meeting2]
          end
        end
      end
    end
  end
end
