# frozen_string_literal: true

require "spec_helper"

describe "Process admin manages meetings attachments", type: :feature do
  include_context "admin"
  let(:user) { process_admin }

  it_behaves_like "manage meetings attachments"
end
