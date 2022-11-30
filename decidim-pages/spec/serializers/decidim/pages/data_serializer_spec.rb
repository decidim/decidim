# frozen_string_literal: true

require "spec_helper"

module Decidim::Pages
  describe DataSerializer do
    let!(:page) { create(:page) }
    let(:serializer) { described_class.new(page.component) }

    describe "#serialize" do
      subject { serializer.serialize }

      it "serializes the page data" do
        expect(subject).to eq({ body: page.body })
      end
    end
  end
end
