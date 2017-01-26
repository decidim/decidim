# frozen_string_literal: true

require "spec_helper"
require_relative "../shared/admin_shared_context"
require_relative "../shared/manage_attachments_examples"

describe "Admin manages meetings attachments", type: :feature do
  include_context "admin"
  it_behaves_like "manage meetings attachments"
end
