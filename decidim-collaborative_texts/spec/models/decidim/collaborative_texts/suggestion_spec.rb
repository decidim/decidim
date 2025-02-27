# frozen_string_literal: true

require "spec_helper"

module Decidim
  module CollaborativeTexts
    describe Suggestion do
      subject { collaborative_text_suggestion }

      let(:collaborative_text_suggestion) { build(:collaborative_text_suggestion) }

      it { is_expected.to be_valid }
    end
  end
end
