# frozen_string_literal: true

require "spec_helper"

require "./db/data/20260909094156_fix_gid_leaking_in_election_titles"

describe FixGidLeakingInElectionTitles do
  let(:migrator) do
    described_class.new.tap do |m|
      m.verbose = false
    end
  end

  describe "#up" do
    let(:organization) { create(:organization) }
    let(:mentioned_user) { create(:user, :confirmed, organization:) }
    let(:user) { create(:user, :confirmed, organization:) }
    let(:component) { create(:elections_component, organization:) }

    context "when an election title contains a GID" do
      let!(:election) do
        create(:election, component:, title: { en: "Title mentioning gid://app/Decidim::User/#{mentioned_user.id}" })
      end

      it "replaces the GID with the user nickname" do
        migrator.migrate(:up)
        election.reload

        expect(election.title["en"]).to eq("Title mentioning @#{mentioned_user.nickname}")
      end
    end

    context "when an election title contains a GID for a non-existent user" do
      let!(:election) do
        create(:election, component:, title: { en: "Title mentioning gid://app/Decidim::User/999999" })
      end

      it "leaves the GID unchanged" do
        migrator.migrate(:up)
        election.reload

        expect(election.title["en"]).to eq("Title mentioning gid://app/Decidim::User/999999")
      end
    end

    context "when an election title does not contain any GID" do
      let!(:election) do
        create(:election, component:, title: { en: "Normal title" })
      end

      it "does not modify the title" do
        migrator.migrate(:up)
        election.reload

        expect(election.title["en"]).to eq("Normal title")
      end
    end

    context "when the table is empty" do
      it "does not raise an error" do
        expect { migrator.migrate(:up) }.not_to raise_error
      end
    end
  end
end
