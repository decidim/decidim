# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe UpdateNavbarLink do
    subject { described_class.new(form, navbar_link) }

    let(:navbar_link) { create :navbar_link }
    let(:organization) { create :organization }
    let(:title) { Decidim::Faker::Localized.literal("New title") }
    let(:link) { Faker::Internet.url }
    let(:weight) { (1..10).to_a.sample }
    let(:target) { ["blank", ""].sample }

    let(:form) do
      double(
        invalid?: invalid,
        title: title,
        link: link,
        weight: weight,
        target: target,
        organization_id: organization.id
      )
    end
    let(:invalid) { false }

    context "when the form is not valid" do
      let(:invalid) { true }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when the form is valid" do
      before do
        subject.call
        navbar_link.reload
      end

      it "updates the link of the NavbarLink" do
        expect(navbar_link.title).to eq(Decidim::Faker::Localized.literal("New title"))
      end

      it "updates the navbar link" do
        expect(navbar_link.link).to eq(link)
      end
    end
  end
end
