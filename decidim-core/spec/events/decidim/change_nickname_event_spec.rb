# frozen_string_literal: true

require "spec_helper"

describe Decidim::ChangeNicknameEvent do
  include_context "when a simple event"

  let(:event_name) { "decidim.events.change_nickname_event" }
  let(:resource) { create(:user) }
  let(:author) { resource }

  describe "notification_title" do
    it "is generated correctly" do
      account_path = Decidim::Core::Engine.routes.url_helpers.account_path

      expect(subject.notification_title).to include("We have corrected the way nicknames are used so that there are no duplicates, and that is why we have removed the case-sensitive rule. <br/> Your nickname was created after another one with the same name, so we have automatically renamed it. You can change it from <a href=\"#{account_path}\">your account settings</a>.")
    end
  end
end
