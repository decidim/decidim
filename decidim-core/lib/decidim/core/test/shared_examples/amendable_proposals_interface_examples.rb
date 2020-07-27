# frozen_string_literal: true

require "spec_helper"

shared_examples_for "amendable proposals interface" do
  describe "amendments" do
    let(:query) do
      "{ amendments {
      state
      amendable { ...on Proposal { title } }
      amendableType
      emendation { ...on Proposal { title } }
      emendationType
      amender { name }
    } }"
    end

    it "includes the amendments states" do
      amendments_states = response["amendments"].map { |amendment| amendment["state"] }
      expect(amendments_states).to include(*model.amendments.map(&:state))
    end

    it "amendable types matches Proposals Type" do
      response["amendments"].each do |amendment|
        expect(amendment["amendableType"]).to eq("Decidim::Proposals::Proposal")
      end
    end

    it "emendation types matches Proposals Type" do
      response["amendments"].each do |amendment|
        expect(amendment["emendationType"]).to eq("Decidim::Proposals::Proposal")
      end
    end

    it "returns amendable as parent proposal" do
      amendment_amendables = response["amendments"].map { |amendment| amendment["amendable"] }
      expect(amendment_amendables).to include(*model.amendments.map(&:amendable).map { |p| { "title" => p.i18n_title } })
    end

    it "returns emendations received" do
      amendment_emendations = response["amendments"].map { |amendment| amendment["emendation"] }
      expect(amendment_emendations).to include(*model.amendments.map(&:emendation).map { |p| { "title" => p.i18n_title } })
    end

    it "returns amender as emendation author" do
      amendment_amenders = response["amendments"].map { |amendment| amendment["amender"] }
      expect(amendment_amenders).to include(*model.amendments.map(&:amender).map { |p| { "name" => p.name } })
    end
  end
end
