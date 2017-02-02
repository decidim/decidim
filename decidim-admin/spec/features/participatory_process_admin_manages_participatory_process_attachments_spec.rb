# frozen_string_literal: true

require "spec_helper"

describe "Participatory process admin manages participatory process attachments", type: :feature do
  include_context "participatory process admin"

  let(:user) { process_admin }

  it_behaves_like "manage process attachments examples"
end
