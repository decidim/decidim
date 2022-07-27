# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe StaticPage do
    let(:page) { build(:static_page) }
    let(:default_pages) { described_class::DEFAULT_PAGES }

    it { is_expected.to be_versioned }

    it "overwrites the log presenter" do
      expect(described_class.log_presenter_class_for(:foo))
        .to eq Decidim::AdminLog::StaticPagePresenter
    end

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

    describe ".sorted_by_i18n_title" do
      let!(:page1) { create :static_page, title: { ca: "Bcde", en: "Afgh" } }
      let!(:page2) { create :static_page, title: { ca: "Abcd", en: "Defg" } }

      before { I18n.locale = :ca }

      after { I18n.locale = :en }

      it "orders by the title in the current locale" do
        expect(described_class.where.not(slug: "terms-and-conditions").sorted_by_i18n_title).to eq [page2, page1]
      end

      it "orders by the title in the specified locale" do
        expect(described_class.where.not(slug: "terms-and-conditions").sorted_by_i18n_title(:en)).to eq [page1, page2]
      end
    end

    describe ".accessible_for" do
      it_behaves_like "accessible static pages" do
        let(:actual_page_ids) do
          described_class.accessible_for(organization, user).pluck(:id)
        end
      end
    end

    describe "#to_param" do
      subject { page.to_param }

      it { is_expected.to eq(page.slug) }
    end

    describe "callbacks" do
      let(:page) { create(:static_page, slug:) }

      context "with a default slug" do
        let(:slug) { default_pages.sample }

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
            expect(page.destroy).to be(false)
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
      subject(:static_page) { build(:static_page, slug:) }

      context "when the slug is a default one" do
        let(:slug) { default_pages.sample }

        it { is_expected.to be_default }
      end

      context "when the slug is a regular one" do
        let(:slug) { "some-slug" }

        it { is_expected.not_to be_default }
      end
    end
  end
end
