# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Amendable
    describe Promote do
      let!(:component) { create(:proposal_component) }
      let!(:other_user) { create(:user, :confirmed, organization: component.organization) }

      let!(:amendable) { create(:proposal, component:) }
      let!(:emendation) { create(:proposal, component:) }
      let!(:amendment) { create :amendment, :rejected, amendable:, emendation: }

      let(:current_user) { amendment.amender }
      let(:context) do
        {
          current_user:,
          current_organization: component.organization
        }
      end

      let(:form) { Decidim::Amendable::PromoteForm.from_model(amendment).with_context(context) }
      let(:command) { described_class.new(form) }

      include_examples "promote amendment"
    end
  end
end
