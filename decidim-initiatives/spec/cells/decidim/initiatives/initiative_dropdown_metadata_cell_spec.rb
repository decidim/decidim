# frozen_string_literal: true

require "spec_helper"

require "decidim/core/test/shared_examples/participatory_space_dropdown_metadata_cell_examples"

module Decidim::Initiatives
  describe InitiativeDropdownMetadataCell, type: :cell do
    controller Decidim::ApplicationController

    subject { cell("decidim/initiatives/initiative_dropdown_metadata", model).call }

    let(:model) { create(:initiative, hashtag:) }
    let(:hashtag) { nil }

    include_examples "participatory space dropdown metadata cell"
    include_examples "participatory space dropdown metadata cell hashtag"
  end
end
