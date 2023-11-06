# frozen_string_literal: true

require "spec_helper"

require "decidim/core/test/shared_examples/participatory_space_dropdown_metadata_cell_examples"

module Decidim::Votings
  describe VotingDropdownMetadataCell, type: :cell do
    controller Decidim::ApplicationController

    subject { cell("decidim/votings/voting_dropdown_metadata", model).call }

    let(:model) { create(:voting) }

    include_examples "participatory space dropdown metadata cell"
  end
end
