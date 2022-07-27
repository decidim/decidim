# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Amendable
    describe DestroyDraft do
      let!(:component) { create(:proposal_component) }
      let!(:other_user) { create(:user, :confirmed, organization: component.organization) }

      let!(:amendable) { create(:proposal, component:) }
      let!(:emendation) { create(:proposal, :unpublished, component:) }
      let!(:amendment) { create(:amendment, :draft, amendable:, emendation:) }

      let(:command) { described_class.new(amendment, current_user) }

      include_examples "destroy amendment draft"
    end
  end
end
