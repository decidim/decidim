# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    describe VersionsController, versioning: true do
      let(:resource) { create(:meeting, :published) }

      it_behaves_like "versions controller"

      context "when the meeting is not published" do
        let(:resource) { create(:meeting) }

        it_behaves_like "versions controller denying unreadable resources"
      end

      context "when the meeting is private" do
        let(:resource) { create(:meeting, :published, private_meeting: true, transparent: false) }

        it_behaves_like "versions controller denying unreadable resources"
      end
    end
  end
end
