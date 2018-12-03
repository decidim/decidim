# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Amendable
    describe Promote do
      let!(:component) { create(:proposal_component) }
      let!(:amendable) { create(:proposal, component: component) }
      let!(:emendation) { create(:proposal, component: component) }
      let!(:amendment) { create :amendment, amendable: amendable, emendation: emendation, state: "rejected" }
      let(:command) { described_class.new(form) }

      let(:form) do
        Decidim::Amendable::PromoteForm
          .from_params(form_params)
          .with_context(context)
      end

      let(:context) do
        {
          current_user: emendation.creator_author
        }
      end

      let(:form_params) do
        {
          id: emendation.id,
          emendation_fields: emendation_fields,
          user_group_id: nil
        }
      end

      let(:emendation_fields) do
        {
          title: emendation.title,
          body: emendation.body
        }
      end

      include_examples "promote amendment"
    end
  end
end
