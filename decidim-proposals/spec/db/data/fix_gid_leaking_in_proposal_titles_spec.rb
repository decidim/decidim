# frozen_string_literal: true

require "spec_helper"

require "./db/data/20260909094157_fix_gid_leaking_in_proposal_titles"

describe FixGidLeakingInProposalTitles do
  let(:migrator) do
    described_class.new.tap do |m|
      m.verbose = false
    end
  end

  describe "#up" do
    let(:organization) { create(:organization) }
    let(:mentioned_user) { create(:user, :confirmed, organization:) }
    let(:component) { create(:proposal_component, organization:) }

    context "when a proposal title contains a GID" do
      let!(:proposal) do
        create(:proposal, component:, title: { en: "Title mentioning gid://app/Decidim::User/#{mentioned_user.id}" })
      end

      it "replaces the GID with the user nickname" do
        migrator.migrate(:up)
        proposal.reload

        expect(proposal.title["en"]).to eq("Title mentioning @#{mentioned_user.nickname}")
      end
    end

    context "when a proposal title contains a GID for a non-existent user" do
      let!(:proposal) do
        create(:proposal, component:, title: { en: "Title mentioning gid://app/Decidim::User/999999" })
      end

      it "leaves the GID unchanged" do
        migrator.migrate(:up)
        proposal.reload

        expect(proposal.title["en"]).to eq("Title mentioning gid://app/Decidim::User/999999")
      end
    end

    context "when a proposal title does not contain any GID" do
      let!(:proposal) do
        create(:proposal, component:, title: { en: "Normal title" })
      end

      it "does not modify the title" do
        migrator.migrate(:up)
        proposal.reload

        expect(proposal.title["en"]).to eq("Normal title")
      end
    end

    context "when the table is empty" do
      it "does not raise an error" do
        expect { migrator.migrate(:up) }.not_to raise_error
      end
    end
  end
end
