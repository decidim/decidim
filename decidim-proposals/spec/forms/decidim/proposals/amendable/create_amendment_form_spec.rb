# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Amendable
    describe CreateForm do
      subject { form }

      let(:amendable) { create(:proposal) }
      let(:amender) { create :user, :confirmed, organization: amendable.organization }

      let(:form) do
        described_class.from_params(form_params).with_context(form_context)
      end

      let(:form_params) do
        {
          amendable_gid: amendable.to_sgid.to_s,
          emendation_params:
        }
      end

      let(:form_context) do
        {
          current_user: amender,
          current_organization: amendable.organization,
          current_participatory_space: amendable.participatory_space,
          current_component: amendable.component
        }
      end

      it_behaves_like "an amendment form"

      context "when the emendation doesn't change the amendable" do
        let(:emendation_params) { { title: translated(amendable.title), body: translated(amendable.body) } }

        it { is_expected.to be_invalid }
      end

      context "when amendable title is not etiquette-compliant" do
        let(:amendable) { create(:proposal, title: "A") }
        let(:emendation_params) { { title: amendable.title, body: "A new body which is long enough" } }

        it { is_expected.to be_valid }
      end

      context "when amendable body is not etiquette-compliant" do
        let(:amendable) { create(:proposal, body: "A") }
        let(:emendation_params) { { title: "A title which is long enough", body: translated(amendable.body) } }

        it { is_expected.to be_valid }
      end

      context "when emendation adds more errors than original" do
        let(:amendable) { create(:proposal, title: "AAAAAAAAAAAAAAAAAAAAAAAAAA") }
        let(:emendation_params) { { title: "AA", body: translated(amendable.body) } }

        it "is invalid" do
          expect(form).to be_invalid
          expect(form.errors[:title]).to eq(["is too short (under 15 characters)"])
        end
      end

      context "when emendation adds less errors than original" do
        let(:amendable) { create(:proposal, title: "1 A!!#?", body: "#$^^ABC") }
        let(:emendation_params) { { title: "A title which is long enough", body: "A new body which is long enough" } }

        it { is_expected.to be_valid }
      end
    end
  end
end
