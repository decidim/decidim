# frozen_string_literal: true

require "spec_helper"

describe Decidim::Surveys::Abilities::CurrentUserAbility do
  let(:organization) { build(:organization) }
  let(:user) { build(:user, organization: organization) }
  let(:participatory_process) { build(:participatory_process, organization: organization) }
  let(:surveys_feature) { build(:surveys_feature, featurable: participatory_process) }
  let(:context) do
    {
      current_feature: surveys_feature
    }
  end

  subject { described_class.new(user, context) }

  it { is_expected.to be_able_to(:answer, Decidim::Surveys::Survey) }
end
