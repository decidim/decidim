# frozen_string_literal: true

require "spec_helper"

describe "Assembly embeds", type: :system do
  let(:resource) { create(:assembly) }

  it_behaves_like "an embed resource", skip_space_checks: true
end
