# frozen_string_literal: true

require "spec_helper"
require "decidim/migrators/username_to_nickname"

module Decidim
  describe Migrators::UsernameToNickname do
    it "copies non-duplicated usernames following slugization rules" do
      user = create(:user, name: "peter")

      subject.migrate!

      expect(user.reload.nickname).to eq("peter")
    end
  end
end
