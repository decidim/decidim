# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe StaticPage do
    let(:page) { build(:static_page) }

    describe "validations" do
      let(:invalid_slug) { "#Invalid.Slug" }

      it "is valid" do
        expect(page).to be_valid
      end

      it "does not allow two pages with the same slug in the same organization" do
        page = create(:static_page)
        invalid_page = build(:static_page, slug: page.slug, organization: page.organization)

        expect(invalid_page).not_to be_valid
      end

      it "does allow two pages with the same slug in different organizations" do
        page = create(:static_page)
        other_page = create(:static_page, slug: page.slug)

        expect(other_page).to be_valid
      end

      it "does not allow to create pages with an invalid slug" do
        page = create(:static_page)
        invalid_page = build(:static_page, slug: invalid_slug, organization: page.organization)

        expect(invalid_page).not_to be_valid
      end
    end

    describe "#to_param" do
      subject { page.to_param }

      it { is_expected.to eq(page.slug) }
    end

    describe "callbacks" do
      let(:page) { create(:static_page, slug: slug) }

      context "with a default slug" do
        let(:slug) { described_class::DEFAULT_PAGES.sample }

        context "when editing" do
          it "makes sure the slug is not changed" do
            page.slug = "foo"
            expect(page.save).to be_falsey

            page.reload
            expect(page.slug).to eq(slug)
          end
        end

        context "when destroying" do
          it "cannot be destroyed" do
            expect(page.destroy).to eq(false)
            expect(page).not_to be_destroyed
          end
        end
      end

      context "with a regular slug" do
        let(:slug) { "some-slug" }

        context "when editing" do
          it "allows changing the slug" do
            page.slug = "foo"
            expect(page.save).to be_truthy

            page.reload
            expect(page.slug).to eq("foo")
          end
        end

        context "when destroying" do
          it "can be destroyed" do
            page.destroy
            expect(page).to be_destroyed
          end
        end
      end
    end

    describe "default?" do
      subject(:static_page) { build(:static_page, slug: slug) }

      context "when the slug is a default one" do
        let(:slug) { described_class::DEFAULT_PAGES.sample }

        it { is_expected.to be_default }
      end

      context "when the slug is a regular one" do
        let(:slug) { "some-slug" }

        it { is_expected.not_to be_default }
      end
    end
  end
end
