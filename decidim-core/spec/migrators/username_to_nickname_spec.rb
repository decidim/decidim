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

    it "slugizes non-duplicated usernames" do
      user = create(:user, name: "Rodríguez San Pedro")

      subject.migrate!

      expect(user.reload.nickname).to eq("rodriguez_san_pedro")
    end

    it "trims very long usernames" do
      user = create(:user, name: "Felipe Juan Froilan de todos los Santos")

      subject.migrate!

      expect(user.reload.nickname).to eq("felipe_juan_froilan_")
    end
  end
end
