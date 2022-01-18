# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe OrganizationPresenter, type: :helper do
    let(:description) { {"en"=>"<p>A necessitatibus quo. 1</p>" } }
    let(:organization) { create(:organization, description: description) }
    let(:subject) { described_class.new(organization) }

    context "with an organization" do
      describe "#translated_description" do
        it "returns the description translated and without any html tag" do
          expect(subject.translated_description).to eq("A necessitatibus quo. 1")
        end
      end
    end
  end
end
