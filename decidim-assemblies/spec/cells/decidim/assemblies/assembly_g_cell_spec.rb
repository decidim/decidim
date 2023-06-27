# frozen_string_literal: true

require "spec_helper"

module Decidim::Assemblies
  describe AssemblyGCell, type: :cell do
    controller Decidim::ApplicationController
    include Decidim::TranslatableAttributes

    subject { cell("decidim/assemblies/assembly_g", model).call }

    let(:model) { create(:assembly, :published) }

    context "when rendering" do
      it "renders the card" do
        expect(subject).to have_content(translated_attribute(model.title))
      end
    end
  end
end
