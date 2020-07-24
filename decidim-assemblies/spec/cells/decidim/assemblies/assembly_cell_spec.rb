# frozen_string_literal: true

require "spec_helper"

module Decidim::Assemblies
  describe AssemblyCell, type: :cell do
    controller Decidim::ApplicationController

    subject { cell("decidim/assemblies/assembly", model).call }

    let(:model) { create(:assembly, :published) }

    it "renders the cell" do
      expect(subject).to have_css(".card--assembly")
    end
  end
end
