# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Accountability
    describe TemplateTexts do
      let(:template_texts) { build :accountability_template_texts }
      subject { template_texts }

      it { is_expected.to be_valid }

      include_examples "has feature"
    end
  end
end
