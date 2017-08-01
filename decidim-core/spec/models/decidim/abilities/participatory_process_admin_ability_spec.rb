# frozen_string_literal: true

require "spec_helper"

describe Decidim::Abilities::ParticipatoryProcessAdminAbility do
  let!(:user) { create(:user, :process_admin, participatory_process: user_process) }

  let(:user_process) { create :participatory_process }

  subject { described_class.new(user, current_participatory_process: user_process) }

  it { is_expected.to be_able_to(:read, user_process) }
end
