# frozen_string_literal: true

require "spec_helper"

module Decidim::Accountability
  describe StatusCell, type: :cell do
    controller Decidim::Accountability::ResultsController

    let!(:component) { create(:accountability_component) }
    let!(:taxonomy) { create(:taxonomy, :with_parent, organization: component.organization) }
    let!(:result) { create(:result, component:, progress: 50) }
    let(:component_settings) { double(display_progress_enabled?: true) }

    def status_cell(model, options = {})
      cell("decidim/accountability/status", model, options).tap do |cell|
        allow(cell).to receive(:component_settings).and_return(component_settings)
        allow(cell).to receive(:current_component).and_return(component)
      end
    end

    context "when rendering a taxonomy" do
      let(:model) { taxonomy }

      context "with results" do
        let!(:result) { create(:result, component:, taxonomies: [taxonomy], progress: 75) }

        it "renders the status" do
          html = status_cell(taxonomy).call
          expect(html).to have_css(".accountability__status")
        end

        it "shows the progress" do
          html = status_cell(taxonomy).call
          expect(html).to have_content("75%")
        end
      end

      context "with no results" do
        it "does not render" do
          expect(status_cell(taxonomy).render?).to be false
        end
      end
    end

    context "when rendering a result" do
      let(:model) { result }

      it "renders the status" do
        html = status_cell(result).call
        expect(html).to have_css(".accountability__status")
      end

      it "shows the progress from the model" do
        html = status_cell(result).call
        expect(html).to have_content("50%")
      end
    end

    context "with custom progress passed via options" do
      let(:model) { result }

      it "does not use custom progress when model has progress" do
        html = status_cell(result, progress: 80).call
        expect(html).to have_content("50%")
        expect(html).to have_no_content("80%")
      end
    end

    context "with custom count passed via options" do
      let(:model) { result }

      it "displays the count" do
        html = status_cell(result, count: 42).call
        expect(html).to have_content("42")
      end
    end

    context "when render_blank option is true" do
      let(:model) { taxonomy }

      it "renders even without results" do
        expect(status_cell(taxonomy, render_blank: true).render?).to be true
      end
    end

    context "when render_count is false" do
      let(:model) { result }

      it "does not display the count" do
        html = status_cell(result, count: 99, render_count: false).call.to_s
        expect(html).not_to include(">99<")
      end
    end
  end
end
