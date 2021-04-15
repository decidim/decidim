# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Question do
  subject(:question) { build(:question) }

  it { is_expected.to be_valid }

  include_examples "resourceable"
end
