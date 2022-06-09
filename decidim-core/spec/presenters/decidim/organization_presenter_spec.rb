# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe OrganizationPresenter, type: :helper do
    let(:description) { { "en" => "<p>A necessitatibus quo. 1</p>" } }
    let(:organization) { create(:organization, name: "Organization's name", description: description) }

    subject { described_class.new(organization) }

    context "with an organization" do
      describe "#html_name" do
        it "returns the description translated and without any html tag" do
          expect(subject.html_name).to eq("Organization's name")
        end
      end

      describe "#translated_description" do
        it "returns the description translated and without any html tag" do
          expect(subject.translated_description).to eq("A necessitatibus quo. 1")
        end
      end

      describe "#start_url" do
        it "returns the url that opens when the installed pwa is launched" do
          expect(subject.start_url).to eq("/")
        end
      end

      describe "#pwa_display" do
        it "returns the pwa_display value" do
          expect(subject.pwa_display).to eq("standalone")
        end
      end
    end
  end
end
