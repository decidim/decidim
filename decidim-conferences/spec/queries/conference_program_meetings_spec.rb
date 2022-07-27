# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe ConferenceProgramMeetings do
    subject { described_class.new(component, user) }

    let(:conference) { create(:conference) }

    let(:component) do
      create(:component, manifest_name: :meetings, participatory_space: conference)
    end

    let(:local_meetings) do
      create_list(
        :meeting,
        3,
        :published,
        component:
      )
    end

    let(:foreign_meetings) do
      create_list(
        :meeting,
        3,
        :published
      )
    end

    describe "query" do
      context "when user is not present" do
        let(:user) { nil }

        it "includes the meetings component" do
          expect(subject).to include(*local_meetings)
        end

        it "excludes the external meetings" do
          expect(subject).not_to include(*foreign_meetings)
        end
      end

      context "when user is present" do
        let!(:user) { create(:user, organization: conference.organization) }

        let!(:local_private_meetings) do
          create_list(
            :meeting,
            3,
            :published,
            component:,
            private_meeting: true
          )
        end

        let!(:registration) { create(:registration, user:, meeting: local_private_meetings.first) }

        it "includes the meetings visible for user" do
          expect(subject).to include(*local_private_meetings.first)
        end
      end
    end
  end
end
