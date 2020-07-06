# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe MeetingSearch do
    subject { described_class.new(params) }

    let(:current_component) { create :component, manifest_name: "meetings" }
    let(:scope1) { create :scope, organization: current_component.organization }
    let(:scope2) { create :scope, organization: current_component.organization }
    let(:parent_category) { create :category, participatory_space: current_component.participatory_space }
    let(:subcategory) { create :subcategory, parent: parent_category }
    let!(:meeting1) do
      create(
        :meeting,
        component: current_component,
        start_time: 1.day.from_now,
        category: parent_category,
        scope: scope1,
        description: Decidim::Faker::Localized.literal("Nulla TestCheck accumsan tincidunt.")
      )
    end
    let!(:meeting2) do
      create(
        :meeting,
        component: current_component,
        start_time: 1.day.ago,
        end_time: 2.days.from_now,
        category: subcategory,
        scope: scope2,
        description: Decidim::Faker::Localized.literal("Curabitur arcu erat, accumsan id imperdiet et.")
      )
    end
    let(:external_meeting) { create :meeting }
    let(:component_id) { current_component.id }
    let(:organization_id) { current_component.organization.id }
    let(:default_params) { { component: current_component, organization: current_component.organization } }
    let(:params) { default_params }

    describe "base query" do
      context "when no component is passed" do
        let(:default_params) { { component: nil } }

        it "raises an error" do
          expect { subject.results }.to raise_error(StandardError, "Missing component")
        end
      end
    end

    describe "filters" do
      context "with component_id" do
        it "only returns meetings from the given component" do
          external_meeting = create(:meeting)

          expect(subject.results).not_to include(external_meeting)
        end
      end

      context "with date" do
        let(:params) { default_params.merge(date: date) }
        let!(:past_meeting) do
          create(:meeting, component: current_component, start_time: 10.days.ago, end_time: 1.day.ago)
        end

        context "when upcoming" do
          let(:date) { ["upcoming"] }

          it "only returns that are scheduled in the future" do
            expect(subject.results).to match_array [meeting1, meeting2]
          end
        end

        context "when past" do
          let(:date) { ["past"] }

          it "only returns meetings that were scheduled in the past" do
            expect(subject.results).to match_array [past_meeting]
          end
        end
      end

      context "with search_text" do
        let(:params) { default_params.merge(search_text: "TestCheck") }

        it "show only the meeting containing the search_text" do
          expect(subject.results).to include(meeting1)
          expect(subject.results.length).to eq(1)
        end
      end

      context "with scope_id" do
        context "when a single id is being sent" do
          let(:params) { default_params.merge(scope_id: scope1.id) }

          it "filters meetings by scope" do
            expect(subject.results).to eq [meeting1]
          end
        end

        context "when multiple ids are sent" do
          let(:params) { default_params.merge(scope_id: [scope2.id, scope1.id]) }

          it "filters meetings by scope" do
            expect(subject.results).to match_array [meeting1, meeting2]
          end
        end

        context "when `global` is being sent" do
          let!(:resource_without_scope) { create(:meeting, component: current_component, scope: nil) }
          let(:params) { default_params.merge(scope_id: ["global"]) }

          it "returns resources without a scope" do
            expect(subject.results).to eq [resource_without_scope]
          end
        end
      end

      context "with category_id" do
        context "when the given category has no subcategories" do
          let(:params) { default_params.merge(category_id: subcategory.id) }

          it "returns only meetings from the given category" do
            expect(subject.results).to eq [meeting2]
          end
        end

        context "when the given category has some subcategories" do
          let(:params) { default_params.merge(category_id: parent_category.id) }

          it "returns meetings from this category and its children's" do
            expect(subject.results).to match_array [meeting2, meeting1]
          end
        end

        context "when the category does not belong to the current component" do
          let(:external_category) { create :category }
          let(:params) { default_params.merge(category_id: external_category.id) }

          it "returns an empty array" do
            expect(subject.results).to eq []
          end
        end
      end
    end
  end
end
