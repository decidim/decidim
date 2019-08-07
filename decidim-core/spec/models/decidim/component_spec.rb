# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Component do
    subject { component }

    let(:component) { build(:component, manifest_name: "dummy") }

    it { is_expected.to be_valid }
    it { is_expected.to be_versioned }

    include_examples "publicable"
    include_examples "resourceable"

    it "overwrites the log presenter" do
      expect(described_class.log_presenter_class_for(:foo))
        .to eq Decidim::AdminLog::ComponentPresenter
    end

    describe "default scope" do
      subject { described_class.all }

      it "orders the components by wieght and by manifest name" do
        described_class.destroy_all

        component_b = create :component, manifest_name: :b, weight: 0
        component_c = create :component, manifest_name: :c, weight: 2
        component_a = create :component, manifest_name: :a, weight: 0

        expect(subject).to eq [component_a, component_b, component_c]
      end
    end
  end
end
