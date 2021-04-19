# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/core/test"

module Decidim
  module Meetings
    describe MeetingsType, type: :graphql do
      include_context "with a graphql class type"
      let(:model) { create(:meeting_component) }

      it_behaves_like "a component query type"

      describe "meetings" do
        let!(:meetings) { create_list(:meeting, 2, component: model) }
        let!(:other_meetings) { create_list(:meeting, 2) }

        let(:query) { "{ meetings { edges { node { id } } } }" }

        it "returns the published meetings" do
          ids = response["meetings"]["edges"].map { |edge| edge["node"]["id"] }
          expect(ids).to include(*meetings.map(&:id).map(&:to_s))
          expect(ids).not_to include(*other_meetings.map(&:id).map(&:to_s))
        end

        context "when private" do
          before do
            meetings.first.update(private_meeting: true, transparent: false)
          end

          it "returns the public meetings" do
            ids = response["meetings"]["edges"].map { |edge| edge["node"]["id"] }
            expect(ids).not_to include(meetings.first.id.to_s)
            expect(ids).to include(meetings.second.id.to_s)
          end
        end
      end

      describe "meeting" do
        let(:query) { "query Meeting($id: ID!){ meeting(id: $id) { id } }" }
        let(:variables) { { id: meeting.id.to_s } }

        context "when the meeting belongs to the component" do
          let!(:meeting) { create(:meeting, component: model) }

          it "finds the meeting" do
            expect(response["meeting"]["id"]).to eq(meeting.id.to_s)
          end
        end

        context "when the meeting doesn't belong to the component" do
          let!(:meeting) { create(:meeting, component: create(:meeting_component)) }

          it "returns null" do
            expect(response["meeting"]).to be_nil
          end
        end

        context "when private" do
          let!(:meeting) { create(:meeting, component: model, private_meeting: true, transparent: false) }

          it "returns null" do
            expect(response["meeting"]).to be_nil
          end
        end
      end
    end
  end
end
