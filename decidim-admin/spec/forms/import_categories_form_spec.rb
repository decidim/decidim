# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe ImportCategoriesForm do
      subject { form }

      let(:category) { create(:category) }
      let(:origin_space) { category.participatory_space }
      let(:organization) { origin_space.organization }
      let(:current_space) { create(:participatory_process, organization: organization) }

      let(:another_category) { create(:category, participatory_space: current_space) }

      let(:params) do
        {
          origin_participatory_space_slug: origin_space.try(:slug)
        }
      end

      let(:form) do
        described_class.from_params(params).with_context(
          current_organization: organization,
          current_participatory_space: current_space,
        )
      end

      context "when everything is OK" do
        it do
          is_expected.to be_valid
        end
      end

      context "when there's no origin participatory space" do
        let(:origin_space) { nil }

        it do
          is_expected.to be_invalid
        end
      end

      describe "origin_space" do
        let(:another_organization) { create(:organization)}
        let(:second_origin_space) { create(:assembly, organization: another_organization) }

        it "ignores participatory spaces from other organisations" do
          expect(form.origin_participatory_space).to be_nil
        end
      end

      describe "origin_spaces" do
        let(:origin_organization) { create(:organization)}
        let(:second_origin_space) { create(:assembly, organization: origin_organization) }

        it "returns available participatory spaces" do
          expect(form.origin_participatory_spaces).to include(second_origin_space)
          expect(form.origin_participatory_spaces.length).to eq(1)
        end
      end
    end
  end
end
