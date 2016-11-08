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
  end
end
