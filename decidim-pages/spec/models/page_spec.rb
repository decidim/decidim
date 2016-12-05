# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Pages
    describe Page do
      let(:page) { create(:page) }

      it "has an associated feature" do
        expect(page.feature).to be_a(Decidim::Feature)
      end

      it "has an I18n title" do
        expect(page.title).to be_a(Hash)
      end
    end
  end
end
