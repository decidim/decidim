# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::Admin::MeetingClosesController, type: :controller do
  context "when proposal linking is not enabled" do
    before do
      allow(Decidim::Meetings).to receive(:enable_proposal_linking).and_return(false)
    end

    it "does not load the proposals admin picker concern" do
      expect(Decidim::Meetings::Admin::MeetingClosesController).not_to receive(:include).with(
        Decidim::Proposals::Admin::Picker
      )

      load "#{Decidim::Meetings::Engine.root}/app/controllers/decidim/meetings/admin/meeting_closes_controller.rb"
    end
  end
end
