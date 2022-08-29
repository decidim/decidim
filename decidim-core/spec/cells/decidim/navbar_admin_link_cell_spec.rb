# frozen_string_literal: true

require "spec_helper"

describe Decidim::NavbarAdminLinkCell, type: :cell do
  controller Decidim::ApplicationController

  subject { cell("decidim/navbar_admin_link", model).call }

  let(:model) { { link_url:, link_options: } }
  let(:link_url) { "https://link.url" }
  let(:link_options) { {} }

  context "when rendering with the defaults" do
    it "renders the link wrapper" do
      expect(subject).to have_css(".topbar__admin__link")
    end

    it "renders the link url" do
      expect(subject).to have_link(href: "https://link.url")
    end

    it "renders the link name: Edit" do
      expect(subject).to have_css("span", text: "Edit")
    end

    it "renders the icon: pencil" do
      expect(subject).to have_css("svg.icon--pencil")
    end
  end

  context "when rendering with custom options" do
    let(:link_url) { "https://another.link.url" }
    let(:link_options) do
      {
        name: "Answer",
        icon: "comment-square",
        class: "my-class"
      }
    end

    it "renders the link url" do
      expect(subject).to have_link(href: "https://another.link.url")
    end

    it "renders the link wrapper with the custom class" do
      expect(subject).to have_css(".topbar__admin__link.my-class")
    end

    it "renders the custom link name: Edit" do
      expect(subject).to have_css("span", text: "Answer")
    end

    it "renders the custom icon: comment" do
      expect(subject).to have_css("svg.icon--comment-square")
    end
  end
end
