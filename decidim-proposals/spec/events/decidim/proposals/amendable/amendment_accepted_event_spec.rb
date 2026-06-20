# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Amendable
    describe AmendmentAcceptedEvent do
      let!(:component) { create(:proposal_component) }
      let!(:amendable) { create(:proposal, component:, title: amendable_title) }
      let!(:emendation) { create(:proposal, component:, title: "My super emendation") }
      let!(:amendment) { create(:amendment, amendable:, emendation:) }
      let(:amendable_title) { "My super proposal" }

      let(:emendation_author_name) { emendation.creator_author.name }
      let(:event_name) { "decidim.events.amendments.amendment_accepted" }
      let(:amendment_type) { "accepted" }
      let(:email_subject) { "Accepted amendment for #{amendable_title} from #{emendation_author_name}" }

      include_examples "amendment event"
    end
  end
end
