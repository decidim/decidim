# frozen_string_literal: true

require "spec_helper"
require "decidim/proposals/test/factories"

describe TranslatedEtiquetteValidator do
  subject { form }

  let(:organization) { create(:organization, available_locales: %w(en es)) }
  let(:participatory_space) { create(:participatory_process, :with_steps, organization:) }
  let(:component) { create(:proposal_component, participatory_space:) }

  let(:form) do
    Decidim::Proposals::Admin::ProposalForm.from_params(params).with_context(
      current_component: component,
      current_organization: organization,
      current_participatory_space: participatory_space
    )
  end

  let(:params) do
    {
      title: {
        en: "A SCREAMING TITLE WITH TOO MANY CAPS"
      },
      body: {
        en: "<p>This is a body with too many marks!!?</p>"
      }
    }
  end

  context "when Decidim.enable_etiquette_validator is false" do
    before do
      allow(Decidim).to receive(:enable_etiquette_validator).and_return(false)
    end

    it "skips validation for all translatable fields" do
      expect(subject).to be_valid
    end
  end

  context "when Decidim.enable_etiquette_validator is true" do
    before do
      allow(Decidim).to receive(:enable_etiquette_validator).and_return(true)
    end

    it "performs validation on translatable fields" do
      expect(subject).not_to be_valid

      # Check that errors are added for the default locale
      expect(subject.errors[:title_en]).not_to be_empty
      expect(subject.errors[:body_en]).not_to be_empty
    end
  end
end
