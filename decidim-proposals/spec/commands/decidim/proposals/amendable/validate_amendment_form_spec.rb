# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Amendable
    describe Validate do
      let!(:component) do
        create(:proposal_component,
               :with_amendments_enabled)
      end
      let!(:user) { create :user, :confirmed, organization: component.organization }
      let!(:amendable) { create(:proposal, component: component) }

      let(:create_command) { described_class.new(create_form) }
      let(:create_form) do
        Decidim::Amendable::CreateForm.from_params(form_params).with_context(form_context)
      end

      let(:accept_command) { described_class.new(review_form) }
      let(:review_form) do
        Decidim::Amendable::CreateForm.from_params(form_params).with_context(form_context)
      end
      let(:form_params) do
        {
          amendable_gid: amendable.to_sgid.to_s,
          emendation_fields: emendation_fields
        }
      end

      let(:form_context) do
        {
          current_user: user,
          current_organization: component.organization,
          current_participatory_space: component.participatory_space,
          current_component: component
        }
      end

      include_examples "validate amendment form"
    end
  end
end
