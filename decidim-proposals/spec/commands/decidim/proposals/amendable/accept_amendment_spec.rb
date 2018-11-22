# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Amendable
    describe Accept do
      let!(:component) { create(:proposal_component) }
      let!(:amendable) { create(:proposal, component: component) }
      let!(:emendation) { create(:proposal, component: component) }
      let!(:amendment) { create :amendment, amendable: amendable, emendation: emendation }
      let(:command) { described_class.new(form) }

      let(:form) { Decidim::Amendable::ReviewForm.from_params(form_params) }

      let(:emendation_fields) do
        {
          title: emendation.title,
          body: emendation.body
        }
      end

      let(:form_params) do
        {
          id: amendment.id,
          amendable_gid: amendable.to_sgid.to_s,
          emendation_gid: emendation.to_sgid.to_s,
          emendation_fields: emendation_fields
        }
      end

      include_examples "accept amendment"
    end
  end
end
