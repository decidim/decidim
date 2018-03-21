# frozen_string_literal: true

require "spec_helper"

describe Decidim::Abilities::ParticipatoryProcessAdminAbility do
  subject { described_class.new(user, current_participatory_space: user_process) }

  let!(:user) { create(:process_admin, participatory_process: user_process) }

  let(:user_process) { create :participatory_process }

  let(:published_component) { create(:component, participatory_space: user_process) }
  let(:unpublished_component) { create(:component, participatory_space: user_process) }

  it { is_expected.to be_able_to(:read, user_process) }
  it { is_expected.to be_able_to(:read, published_component) }
  it { is_expected.to be_able_to(:read, unpublished_component) }
end
