# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe NavbarLink do
    subject { navbar_link }

    let(:organization) { build(:organization) }
    let(:navbar_link) { build(:navbar_link, organization: organization) }

    it "has an association for organisation" do
      expect(subject.organization).to eq(organization)
    end

    describe "validations" do
      it "is valid" do
        expect(subject).to be_valid
      end

      it "is not valid without an organisation" do
        subject.organization = nil
        expect(subject).not_to be_valid
      end

      describe "#validate_link_regex" do
        it "return nil if link is not parsable" do
          subject.link = "foo"
          subject.save
          expect(subject.validate_link_regex).to eq nil
        end

        it "adds an error with specific message" do
          subject.link = "%!,;"
          subject.save
          expect(subject.errors[:link]).to include("is invalid")
        end
      end
    end
  end
end
