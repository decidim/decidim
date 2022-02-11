# frozen_string_literal: true

require "spec_helper"

describe Decidim::ChangeNicknameEvent do
  include_context "when a simple event"

  let(:event_name) { "decidim.events.change_nickname_event" }
  let(:resource) { create :user }
  let(:author) { resource }
  let(:extra) { { old_nickname: "Nick", new_nickname: "nick" } }

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title).to include("Your nickname has been modified from #{extra[:old_nickname]} to #{extra[:new_nickname]} because of new regulations.")
    end
  end
end
