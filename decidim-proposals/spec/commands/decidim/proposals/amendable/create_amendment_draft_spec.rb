# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Amendable
    describe CreateDraft do
      let!(:component) { create(:proposal_component, :with_amendments_enabled) }
      let!(:user) { create :user, :confirmed, organization: component.organization }
      let!(:amendable) { create(:proposal, component:) }

      let(:title) { "More sidewalks and less roads!" }
      let(:body) { "Everything would be better" }

      let(:params) do
        {
          amendable_gid: amendable.to_sgid.to_s,
          emendation_params: { title:, body: }
        }
      end

      let(:context) do
        {
          current_user: user,
          current_organization: component.organization
        }
      end

      let(:form) { Decidim::Amendable::CreateForm.from_params(params).with_context(context) }
      let(:command) { described_class.new(form) }

      include_examples "create amendment draft"
    end
  end
end
