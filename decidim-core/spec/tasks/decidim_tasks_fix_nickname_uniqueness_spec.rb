# frozen_string_literal: true

require "spec_helper"

describe "rake decidim:upgrade:fix_nickname_uniqueness", type: :task do
  let!(:user1) { create(:user, :confirmed, nickname: "toto") }
  let!(:user2) { create(:user, :confirmed, nickname: "Toto") }
  let!(:user3) { create(:user, :confirmed, nickname: "TOTO") }
  let!(:user4) { create(:user, :confirmed, nickname: "foO") }
  let!(:user5) { create(:user, :confirmed, nickname: "Foo") }

  context "when executing task" do
    it "have to be executed without failures" do
      allow($stdin).to receive(:gets).and_return("N")
      expect { task.execute }.not_to raise_error
    end

    it "has to change nicknames" do
      task.execute
      expect(user1.reload.nickname).to eq("toto")
      expect(user2.reload.nickname).to match(/Toto-\d{0,5}/)
      expect(user3.reload.nickname).to match(/TOTO-\d{0,5}/)
      expect(user4.reload.nickname).to eq("foO")
      expect(user5.reload.nickname).to match(/Foo-\d{0,5}/)
    end

    it "send notifications" do
      expect(Decidim::EventsManager).to receive(:publish).exactly(3).times

      task.execute

    end
  end
end
