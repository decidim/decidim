# frozen_string_literal: true

require "spec_helper"

describe "Process embeds", type: :system do
  let(:resource) { create(:participatory_process) }

  it_behaves_like "an embed resource", skip_space_checks: true
end
