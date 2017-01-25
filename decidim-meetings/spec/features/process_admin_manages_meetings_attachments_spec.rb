# frozen_string_literal: true

require "spec_helper"
require_relative "../shared/admin_shared_context"
require_relative "../shared/manage_attachments_examples"

describe "Process admin manages meetings attachments", type: :feature do
  include_context "admin"
  let(:user) { process_admin }

  it_behaves_like "manage meetings attachments"
end
