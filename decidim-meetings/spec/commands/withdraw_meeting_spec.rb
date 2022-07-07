# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    describe WithdrawMeeting do
      let(:meeting) { create(:meeting) }

      before do
        meeting.save!
      end

      context "when current user IS the author of the meeting" do
        let(:current_user) { meeting.author }
        let(:command) { described_class.new(meeting, current_user) }

        it "withdraws the meeting" do
          expect { command.call }.to broadcast(:ok)
          expect(meeting.state).to eq("withdrawn")
        end
      end

      context "when current user IS NOT the author of the meeting" do
        let(:current_user) { create(:user, :admin) }
        let(:command) { described_class.new(meeting, current_user) }

        it "does not withdraw the meeting" do
          expect { command.call }.to broadcast(:invalid)
          expect(meeting.state).to be_nil
        end
      end
    end
  end
end
