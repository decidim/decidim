# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::MeetingClosesController, type: :controller do
  context "when proposal linking is not enabled" do
    before do
      allow(Decidim::Meetings).to receive(:enable_proposal_linking).and_return(false)
    end

    after do
      # Re-enable proposal linking before reloading the class
      allow(Decidim::Meetings).to receive(:enable_proposal_linking).and_return(true)

      # Reload the class with proposal linking enabled
      Decidim::Meetings.send(:remove_const, :MeetingClosesController)
      load "#{Decidim::Meetings::Engine.root}/app/controllers/decidim/meetings/meeting_closes_controller.rb"
    end

    it "does not load the proposals admin picker concern" do
      Decidim::Meetings.send(:remove_const, :MeetingClosesController)
      load "#{Decidim::Meetings::Engine.root}/app/controllers/decidim/meetings/meeting_closes_controller.rb"

      # Do not use `described_class` here because it is referring to the
      # previously defined class.
      expect(
        Decidim::Meetings::MeetingClosesController.include?(Decidim::Proposals::Admin::Picker)
      ).to be(false)
    end
  end
end
