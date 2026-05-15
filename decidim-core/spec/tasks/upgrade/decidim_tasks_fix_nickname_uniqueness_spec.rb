# frozen_string_literal: true

require "spec_helper"

describe "rake decidim:upgrade:fix_nickname_uniqueness", type: :task do
  context "when all users come from the same organization" do
    let(:organization) { create(:organization) }
    let!(:user1) do
      user = build(:user, :confirmed, nickname: "toto", organization:)
      user.save(validate: false)
      user
    end
    let!(:user2) do
      user = build(:user, :confirmed, nickname: "Toto", organization:)
      user.save(validate: false)
      user
    end
    let!(:user3) do
      user = build(:user, :confirmed, nickname: "TOTO", organization:)
      user.save(validate: false)
      user
    end
    let!(:user4) do
      user = build(:user, :confirmed, nickname: "foO", organization:)
      user.save(validate: false)
      user
    end
    let!(:user5) do
      user = build(:user, :confirmed, nickname: "Foo", organization:)
      user.save(validate: false)
      user
    end

    context "when executing task" do
      it "have to be executed without failures" do
        allow($stdin).to receive(:gets).and_return("N")
        expect { task.execute }.not_to raise_error
      end

      it "has to change nicknames" do
        task.execute
        expect(user1.reload.nickname).to eq("toto")
        expect(user2.reload.nickname).to eq("toto_2")
        expect(user3.reload.nickname).to eq("toto_3")
        expect(user4.reload.nickname).to eq("foo")
        expect(user5.reload.nickname).to eq("foo_2")
      end

      it "send notifications" do
        expect(Decidim::EventsManager).to receive(:publish).exactly(3).times

        task.execute
      end
    end
  end

  context "when users come from different organizations" do
    let(:organization1) { create(:organization) }
    let(:organization2) { create(:organization) }
    let!(:user1) do
      user = build(:user, :confirmed, nickname: "toto", organization: organization1)
      user.save(validate: false)
      user
    end
    let!(:user2) do
      user = build(:user, :confirmed, nickname: "Toto", organization: organization1)
      user.save(validate: false)
      user
    end
    let!(:user3) do
      user = build(:user, :confirmed, nickname: "TOTO", organization: organization2)
      user.save(validate: false)
      user
    end
    let!(:user4) do
      user = build(:user, :confirmed, nickname: "foO", organization: organization1)
      user.save(validate: false)
      user
    end
    let!(:user5) do
      user = build(:user, :confirmed, nickname: "Foo", organization: organization2)
      user.save(validate: false)
      user
    end

    context "when executing task" do
      it "have to be executed without failures" do
        allow($stdin).to receive(:gets).and_return("N")
        expect { task.execute }.not_to raise_error
      end

      it "has to change nicknames" do
        task.execute

        expect(user1.reload.nickname).to eq("toto")
        expect(user2.reload.nickname).to eq("toto_2")
        expect(user3.reload.nickname).to eq("toto")
        expect(user4.reload.nickname).to eq("foo")
        expect(user5.reload.nickname).to eq("foo")
      end

      it "send notifications" do
        expect(Decidim::EventsManager).to receive(:publish).once

        task.execute
      end
    end
  end
end
