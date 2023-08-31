# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Amendable
    describe AmendmentRejectedEvent do
      let!(:component) { create(:proposal_component) }
      let!(:amendable) { create(:proposal, component:, title: amendable_title) }
      let!(:emendation) { create(:proposal, component:, title: "My super emendation") }
      let!(:amendment) { create(:amendment, amendable:, emendation:) }
      let(:amendable_title) { "My super proposal" }

      let(:event_name) { "decidim.events.amendments.amendment_rejected" }
      let(:amendment_type) { "rejected" }
      let(:email_subject) { "Amendment rejected for #{amendable_title} from #{emendation_author_nickname}" }

      include_examples "amendment event"
    end
  end
end
