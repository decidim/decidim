# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Amendable
    describe CreateDraft do
      let!(:component) { create(:proposal_component, :with_amendments_enabled) }
      let!(:user) { create(:user, :confirmed, organization: component.organization) }
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

      context "when proposal has a category association" do
        let(:category) { create(:category, participatory_space: component.participatory_space) }
        let!(:amendable) { create(:proposal, component:, category:) }

        it "copies the Proposal category" do
          expect { command.call }
            .to change(Decidim::Amendment, :count)
            .by(1)
            .and change(amendable.class, :count)
            .by(1)

          amendable.reload

          expect(Decidim::Amendment.last).to be_draft
          expect(amendable.class.last).not_to be_published
          expect(amendable.emendations.count).to eq(1)
          expect(amendable.category.id).to eq(category.id)
          expect(amendable.emendations.first.category.id).to eq(category.id)
        end
      end
    end
  end
end
