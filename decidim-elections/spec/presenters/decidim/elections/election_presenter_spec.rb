# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Elections
    describe ElectionPresenter, type: :helper do
      subject(:presenter) { described_class.new(election) }

      let(:organization) { create(:organization) }
      let(:participatory_process) { create(:participatory_process, organization:) }
      let(:component) { create(:elections_component, participatory_space: participatory_process) }

      let(:election) do
        create(:election,
               component: component,
               title: { en: "Test election" },
               description: {
                 en: "Test description",
                 machine_translations: { es: "Descripción de prueba" }
               })
      end

      describe "#title" do
        it "returns the election title" do
          expect(presenter.title).to eq("Test election")
        end

        it "returns the translated title when all_locales is true" do
          expect(presenter.title(all_locales: true)).to eq("en" => "Test election")
        end
      end

      describe "#description" do
        it "returns the description in current locale" do
          expect(presenter.description).to eq("Test description")
        end

        it "returns all locales if all_locales is true" do
          expect(presenter.description(all_locales: true)).to eq({
                                                                   "en" => "Test description",
                                                                   "machine_translations" => { "es" => "Descripción de prueba" }
                                                                 })
        end

        it "strips HTML if strip_tags is true" do
          election_with_html = create(
            :election,
            component: component,
            description: { en: "<p>Hello world</p>" }
          )
          presenter_html = described_class.new(election_with_html)

          expect(presenter_html.description(strip_tags: true).strip).to eq("Hello world")
        end
      end

      describe "#election_path" do
        it "returns the public path for the election" do
          allow(Decidim::ResourceLocatorPresenter).to receive(:new)
            .with(election)
            .and_return(double(path: "/elections/123"))

          expect(presenter.election_path).to eq("/elections/123")
        end
      end

      context "when election is nil" do
        let(:presenter) { described_class.new(nil) }

        it { expect(presenter.title).to be_nil }
        it { expect(presenter.description).to be_nil }
        it { expect(presenter.election_path).to be_nil }
      end
    end
  end
end
