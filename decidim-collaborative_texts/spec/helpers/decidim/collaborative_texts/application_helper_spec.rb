# frozen_string_literal: true

require "spec_helper"

module Decidim
  module CollaborativeTexts
    describe ApplicationHelper do
      let(:component) { double("Component", name: { en: "Collaborative Texts on fire!" }) }

      before do
        allow(helper).to receive(:current_component).and_return(component)
      end

      describe "#component_name" do
        it "returns the translated name of the current component when defined" do
          expect(helper.component_name).to eq("Collaborative Texts on fire!")
        end
      end

      describe "#document_i18n" do
        it "returns the expected i18n keys with translations" do
          expect(helper.document_i18n.keys).to contain_exactly(:consolidateConfirm, :rolloutConfirm, :selectionActive)
        end
      end
    end
  end
end
