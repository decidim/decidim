# coding: utf-8
# frozen_string_literal: true
require "spec_helper"

describe "Show a page", type: :feature do
  include_context "feature"
  let(:manifest_name) { "pages" }

  let(:title) do
    {
      "en" => "Hello world",
      "ca" => "Hola món",
      "es" => "Hola mundo"
    }
  end

  let(:body) do
    {
      "en" => "<p>Content</p>",
      "ca" => "<p>Contingut</p>",
      "es" => "<p>Contenido</p>"
    }
  end

  describe "page show" do  
    before do
      create(:page, feature: feature, title: title, body: body)
      visit_feature
    end

    it "renders the content of the page" do
      expect(page).to have_title("Hello world")
      expect(page).to have_content("Content")
    end
  end

  describe "page show with comments" do
    let!(:page_feature) { create(:page, feature: feature, title: title, body: body) }
    let!(:comments) { 3.times.map { create(:comment, commentable: page_feature) } }

    context "if page is commentable" do
      before do
        page_feature.update_attribute(:commentable, true)
      end

      it "renders the comments of the page" do
        visit_feature
        expect(page).to have_selector('.comment', count: comments.length)

        comments.each do |comment|
          expect(page).to have_content comment.body
        end
      end
    end

    context "if page is commentable" do
      before do
        page_feature.update_attribute(:commentable, false)
      end

      it "doesn't render the comments of the page" do
        visit_feature
        expect(page).not_to have_selector('.comment', count: comments.length)
      end
    end
  end
end
