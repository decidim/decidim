# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::Meeting do
  let(:meeting) { build :meeting }
  subject { meeting }

  it { is_expected.to be_valid }
end
