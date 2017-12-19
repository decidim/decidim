# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Nicknamizable do
    subject do
      class DummyTestUser < ApplicationRecord
        self.table_name = :decidim_users

        include Nicknamizable
      end
    end

    it "validates length of nickname" do
      expect(subject.new(nickname: "A" * 20)).to be_valid
      expect(subject.new(nickname: "A" * 21)).not_to be_valid
    end

    describe "#nicknamize" do
      it "copies non-duplicated usernames following slugization rules" do
        expect(subject.nicknamize("peter")).to eq("peter")
      end

      it "slugizes non-duplicated usernames" do
        expect(subject.nicknamize("Rodríguez San Pedro")).to eq("rodriguez_san_pedro")
      end

      it "trims very long usernames" do
        expect(subject.nicknamize("Felipe Juan Froilan de todos los Santos"))
          .to eq("felipe_juan_froilan_d")
      end

      it "resolves conflicts with current nicknames" do
        create(:user, nickname: "ana_pastor")

        expect(subject.nicknamize("ana_pastor")).to eq("ana_pastor_2")
      end

      it "resolves conflicts with long current nicknames" do
        create(:user, nickname: "felipe_rocks_so_much")

        expect(subject.nicknamize("Felipe Rocks So Much")).to eq("felipe_rocks_so_muc_2")
      end
    end
  end
end
