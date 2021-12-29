# frozen_string_literal: true

require "spec_helper"

describe "Key ceremony", type: :system do
  include Decidim::Elections::FullElectionHelpers
  context "when performing the key ceremony", :slow, download: true do
    include_context "when performing the whole process"

    it "generates backup keys, restores them and creates election keys" do
      setup_election

      download_election_keys(0)
      download_election_keys(1)
      download_election_keys(2)

      complete_key_ceremony(0)
      check_key_ceremony_completed(1)
      check_key_ceremony_completed(2)
    end
  end
end
