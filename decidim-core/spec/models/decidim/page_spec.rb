require "spec_helper"

module Decidim
  describe Page do
    let(:page) { build(:page) }

    context "validations" do
      it "is valid" do
        expect(page).to be_valid
      end

      it "does not allow two pages with the same slug in the same organization" do
        page = create(:page)
        invalid_page = build(:page, slug: page.slug, organization: page.organization)

        expect(invalid_page).to_not be_valid
      end

      it "does allow two pages with the same slug in different organizations" do
        page = create(:page)
        other_page = create(:page, slug: page.slug)

        expect(other_page).to be_valid
      end
    end

    describe "to_param" do
      subject { page.to_param }

      it { is_expected.to eq(page.slug) }
    end

    context "callbacks" do
      let(:page) { create(:page, slug: slug) }

      context "pages with a default slug" do
        let(:slug) { Page::DEFAULT_PAGES.sample }

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
            expect(page).to_not be_destroyed
          end
        end
      end

      context "pages with a regular slug" do
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
      subject(:page) { build(:page, slug: slug) }

      context "when the slug is a default one" do
        let(:slug) { Decidim::Page::DEFAULT_PAGES.sample }
        it { is_expected.to be_default }
      end

      context "when the slug is a regular one" do
        let(:slug) { "some-slug" }
        it { is_expected.to_not be_default }
      end
    end
  end
end
