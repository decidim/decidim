# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ParticipatoryProcessType do
    subject(:participatory_process_type) { build(:participatory_process_type) }

    it { is_expected.to be_valid }

    context "without title" do
      subject(:participatory_process_type) { build(:participatory_process_type, title: { en: "My title" }) }

      before do
        participatory_process_type.title = {}
      end

      it { is_expected.to be_invalid }
    end

    context "without organization" do
      before do
        participatory_process_type.organization = nil
      end

      it { is_expected.to be_invalid }
    end

    describe "has an association for children processes" do
      subject(:children) { participatory_process_type.processes }

      let(:processes) { create_list(:participatory_process, 2, participatory_process_type:) }

      it { is_expected.to contain_exactly(*processes) }
    end
  end
end
