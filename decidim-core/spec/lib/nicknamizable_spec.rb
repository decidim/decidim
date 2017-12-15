# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Nicknamizable do
    subject do
      class DummyTestUser < ApplicationRecord
        self.table_name = :decidim_users

        extend Nicknamizable
      end
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
          .to eq("felipe_juan_froilan_")
      end

      it "resolves conflicts with current nicknames" do
        create(:user, nickname: "ana_pastor")

        expect(subject.nicknamize("ana_pastor")).to eq("ana_pastor_2")
      end
    end
  end
end
