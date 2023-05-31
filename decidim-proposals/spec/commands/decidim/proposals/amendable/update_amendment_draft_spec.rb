# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Amendable
    describe UpdateDraft do
      let!(:component) { create(:proposal_component) }
      let!(:other_user) { create(:user, :confirmed, organization: component.organization) }

      let!(:amendable) { create(:proposal, component:) }
      let!(:emendation) { create(:proposal, :unpublished, component:) }
      let!(:amendment) { create(:amendment, :draft, amendable:, emendation:) }

      let(:title) { "More sidewalks and less roads!" }
      let(:body) { "Everything would be better" }
      let(:params) do
        {
          id: amendment.id,
          emendation_params: { title:, body: }
        }
      end

      let(:current_user) { amendment.amender }
      let(:context) do
        {
          current_user:,
          current_organization: component.organization
        }
      end

      let(:form) { Decidim::Amendable::EditForm.from_params(params).with_context(context) }
      let(:command) { described_class.new(form) }

      include_examples "update amendment draft"
    end
  end
end
