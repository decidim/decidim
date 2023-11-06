# frozen_string_literal: true

require "spec_helper"

module Decidim::Blogs
  describe PostGCell, type: :cell do
    controller Decidim::ApplicationController
    include Decidim::TranslatableAttributes

    subject { cell("decidim/blogs/post_g", model).call }

    let(:model) { create(:post) }

    context "when rendering" do
      it "renders the card" do
        expect(subject).to have_content(translated_attribute(model.title))
      end
    end
  end
end
