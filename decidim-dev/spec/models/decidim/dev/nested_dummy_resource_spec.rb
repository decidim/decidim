# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Dev
    describe NestedDummyResource do
      subject { nested_dummy_resource }

      let(:dummy_resource) { create(:dummy_resource) }
      let(:nested_dummy_resource) { create(:nested_dummy_resource, dummy_resource:) }

      it { is_expected.to be_valid }
    end
  end
end
