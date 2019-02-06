# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe ImportParticipatoryTextForm do
        subject { form }

        let(:component) { create :component }
        let(:title) do
          {
            ca: "Yes very good, patates amb suc",
            en: "Si molt bé, potatoes with sauce",
            es: "Ya para ser feliz quiero un camión"
          }
        end
        let(:description) {}
        let(:document) { Decidim::Dev.test_file("participatory_text.md", "text/markdown") }
        
        let(:params) do
          {
            title: title,
            description: description,
            document: document
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

        context "when the document is not valid" do
          let(:document_file) { nil }

          it { is_expected.to be_valid }
        end
      end
    end
  end
end
