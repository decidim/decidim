# frozen_string_literal: true

require "spec_helper"

module Decidim
  module CollaborativeTexts
    describe ApplicationHelper do
      let(:component) { double("Component", name: { en: "Collaborative Texts" }) }

      before do
        allow(helper).to receive(:current_component).and_return(component)
        allow(helper).to receive(:translated_attribute).with(component.name).and_return("Collaborative Texts")
      end

      describe "#component_name" do
        it "returns the translated name of the current component when defined" do
          expect(helper.component_name).to eq("Collaborative Texts")
        end

        it "returns the default translation when no current_component is defined" do
          allow(helper).to receive(:current_component).and_return(nil)
          allow(helper).to receive(:translated_attribute).with(nil).and_return(nil)

          expect(helper.component_name).to eq(I18n.t("decidim.components.collaborative_texts.name"))
        end
      end

      describe "#document_i18n" do
        it "returns the expected i18n keys with translations" do
          allow(helper).to receive(:t).with("decidim.collaborative_texts.document.suggest").and_return("Suggest Translation")
          allow(helper).to receive(:t).with("decidim.collaborative_texts.document.cancel").and_return("Cancel Translation")
          allow(helper).to receive(:t).with("decidim.collaborative_texts.document.save").and_return("Save Translation")

          expect(helper.document_i18n).to eq(
            {
              suggest: "Suggest Translation",
              cancel: "Cancel Translation",
              save: "Save Translation"
            }
          )
        end
      end
    end
  end
end
