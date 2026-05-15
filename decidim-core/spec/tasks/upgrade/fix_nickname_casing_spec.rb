# frozen_string_literal: true

require "spec_helper"

describe "rake decidim:upgrade:fix_nickname_casing", type: :task do
  let!(:organization) { create(:organization) }

  it "does not throw exceptions" do
    expect { task.execute }.not_to raise_exception
  end

  context "when there are users with same nicknames" do
    let!(:user) do
      user = build(:user, nickname: "SomeCapitalGuy", organization:)
      user.save(validate: false)
      user
    end
    let!(:user2) do
      user = build(:user, nickname: "somecapitalguy", organization:)
      user.save(validate: false)
      user
    end

    it "changes the user" do
      expect { task.execute }.to(change { user.reload.nickname })

      expect(user.nickname).to start_with("somecapitalguy")
    end

    it "does not change the safe user" do
      expect { task.execute }.not_to(change { user2.reload.nickname })
    end
  end

  context "when there are 2 users with same nicknames across multiple organizations" do
    let!(:user) do
      user = build(:user, nickname: "SomeCapitalGuy")
      user.save(validate: false)
      user
    end
    let!(:user2) do
      user = build(:user, nickname: "SomeCapitalGuy", organization:)
      user.save(validate: false)
      user
    end

    it "changes both users correctly" do
      task.execute

      expect(user.reload.nickname).to eq("somecapitalguy")
      expect(user2.reload.nickname).to eq("somecapitalguy")
    end
  end
end
