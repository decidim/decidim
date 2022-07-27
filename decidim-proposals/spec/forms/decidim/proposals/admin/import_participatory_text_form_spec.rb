# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe ImportParticipatoryTextForm do
        subject { form }

        let(:component) { create :component, manifest_name: "proposals" }
        let(:title) do
          {
            ca: "Yes very good, patates amb suc",
            en: "Si molt bé, potatoes with sauce",
            es: "Ya para ser feliz quiero un camión"
          }
        end
        let(:description) { nil }
        let(:document) { upload_test_file(Decidim::Dev.test_file("participatory_text.md", "text/markdown")) }

        let(:params) do
          {
            title:,
            description:,
            document:
          }
        end

        let(:form) do
          described_class.from_params(params).with_context(
            current_component: component,
            current_participatory_space: component.participatory_space
          )
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "when the title is not valid" do
          let(:title) { nil }

          it { is_expected.to be_invalid }
        end

        context "when creating a participatory_text" do
          context "when the document is not valid" do
            let(:document) { nil }

            it { is_expected.to be_invalid }
          end
        end

        context "when updating a participatory_text which has existing proposals" do
          let!(:proposal) { create :proposal, component: }

          context "when the document is not valid" do
            let(:document) { nil }

            it { is_expected.to be_valid }
          end
        end
      end
    end
  end
end
