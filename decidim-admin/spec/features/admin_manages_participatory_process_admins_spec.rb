# frozen_string_literal: true

require "spec_helper"
require_relative "../shared/participatory_admin_shared_context"
require_relative "../shared/manage_process_admins_examples"

describe "Admin manages participatory process admins", type: :feature do
  include_context "participatory process admin"
  it_behaves_like "manage process admins examples"
end
