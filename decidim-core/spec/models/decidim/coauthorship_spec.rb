# frozen_string_literal: true

require "spec_helper"

describe Decidim::Coauthorship do
  subject { coauthorship }

  let(:coauthorship) { build(:coauthorship, coauthorable:, author:) }
  let(:coauthorable) { build(:dummy_resource) }
  let(:organization) { coauthorable.component.participatory_space.organization }
  let(:author) { build(:user, :confirmed, organization:) }

  describe "validations" do
    context "when the coauthorable is nil" do
      before do
        coauthorship.coauthorable = nil
      end

      it { is_expected.to be_invalid }
    end

    context "when the author is from another organization" do
      before do
        subject.author = create(:user)
      end

      it { is_expected.to be_invalid }
    end
  end

  describe "after_commit" do
    context "when the author is a user" do
      shared_examples "followable coauthorable resource" do
        it "adds a follow for the user author" do
          expect { coauthorship.save! }.to change(Decidim::Follow, :count).by(1)
          expect(coauthorable.followers).to include(author)
        end
      end

      it_behaves_like "followable coauthorable resource"

      context "and the author is not confirmed" do
        let(:author) { build(:user, organization:) }

        it_behaves_like "followable coauthorable resource"
      end
    end
  end
end
