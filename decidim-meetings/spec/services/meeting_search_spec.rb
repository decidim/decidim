# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe MeetingSearch do
    subject { described_class.new(params).results }

    let(:component) { create :component, manifest_name: "meetings" }
    let(:default_params) { { component: component, organization: component.organization } }
    let(:params) { default_params }

    it_behaves_like "a resource search", :meeting
    it_behaves_like "a resource search with scopes", :meeting
    it_behaves_like "a resource search with categories", :meeting

    describe "filters" do
      let!(:meeting1) do
        create(
          :meeting,
          component: component,
          start_time: 1.day.from_now,
          description: Decidim::Faker::Localized.literal("Nulla TestCheck accumsan tincidunt.")
        )
      end
      let!(:meeting2) do
        create(
          :meeting,
          component: component,
          start_time: 1.day.ago,
          end_time: 2.days.from_now,
          description: Decidim::Faker::Localized.literal("Curabitur arcu erat, accumsan id imperdiet et.")
        )
      end

      context "with date" do
        let(:params) { default_params.merge(date: date) }
        let!(:past_meeting) do
          create(:meeting, component: component, start_time: 10.days.ago, end_time: 1.day.ago)
        end

        context "when upcoming" do
          let(:date) { ["upcoming"] }

          it "only returns that are scheduled in the future" do
            expect(subject).to match_array [meeting1, meeting2]
          end
        end

        context "when past" do
          let(:date) { ["past"] }

          it "only returns meetings that were scheduled in the past" do
            expect(subject).to match_array [past_meeting]
          end
        end
      end

      context "with search_text" do
        let(:params) { default_params.merge(search_text: "TestCheck") }

        it "show only the meeting containing the search_text" do
          expect(subject).to include(meeting1)
          expect(subject.length).to eq(1)
        end
      end
    end
  end
end
