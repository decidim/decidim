# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Amendable
    describe EmendationPromotedEvent do
      let!(:component) { create(:proposal_component) }
      let!(:amendable) { create(:proposal, component:, title: amendable_title) }
      let!(:emendation) { create(:proposal, component:, title: "My super emendation") }
      let!(:amendment) { create :amendment, amendable:, emendation: }
      let(:amendable_type) { "proposal" }
      let(:amendable_title) { "My super proposal" }

      include_examples "amendment promoted event"
    end
  end
end
