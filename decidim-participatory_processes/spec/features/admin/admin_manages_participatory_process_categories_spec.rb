# frozen_string_literal: true

require "spec_helper"

describe "Admin manages participatory process categories", type: :feature do
  include_context "participatory process administration by admin"

  let!(:category) { create(:category, featurable: participatory_process) }

  it_behaves_like "manage process categories examples"
end
