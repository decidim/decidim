# frozen_string_literal: true

require "spec_helper"
require_relative "../shared/participatory_admin_shared_context"
require_relative "../shared/manage_process_steps_examples"

describe "Admin manages participatory process steps", type: :feature do
  include_context "participatory process admin"
  it_behaves_like "manage process steps examples"
end
