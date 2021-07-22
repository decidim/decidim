# frozen_string_literal: true

require "spec_helper"

module Decidim::Blogs
  describe PostMCell, type: :cell do
    controller Decidim::Blogs::PostsController

    subject { cell_html }

    let(:component) { create(:post_component) }
    let!(:post) { create(:post, component: component) }
    let(:model) { post }
    let(:cell_html) { cell("decidim/blogs/post_m", post, context: { show_space: show_space }).call }

    it_behaves_like "has space in m-cell"

    context "when rendering" do
      let(:show_space) { false }

      it "renders the card" do
        expect(subject).to have_css(".card--post")
      end
    end
  end
end
