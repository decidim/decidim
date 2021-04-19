# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Action do
  subject(:action) { build(:action) }

  it { is_expected.to be_valid }
end
