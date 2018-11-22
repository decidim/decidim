# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Amendable
    describe Reject do
      let!(:component) { create(:proposal_component) }
      let!(:amendable) { create(:proposal, component: component) }
      let!(:emendation) { create(:proposal, component: component) }
      let!(:amendment) { create :amendment, amendable: amendable, emendation: emendation }
      let(:command) { described_class.new(form) }

      let(:form) { Decidim::Amendable::RejectForm.from_params(form_params) }

      let(:form_params) do
        {
          id: amendment.id
        }
      end

      include_examples "reject amendment"
    end
  end
end
