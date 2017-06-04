# frozen_string_literal: true

require "spec_helper"
require_relative "../shared/admin_shared_context"
require_relative "../shared/manage_attachments_examples"

describe "Process admin manages project attachments", type: :feature do
  let(:user) { process_admin }

  include_context "admin"

  it_behaves_like "manage project attachments"
end
