# frozen_string_literal: true

require "spec_helper"

describe "decidim_elections:generate_identification_keys", type: :task do
  it "runs gracefully" do
    expect { task.execute }.not_to raise_error
  end

  context "with the task output" do
    before { task.execute }

    it "includes the private key" do
      check_message_printed("-----BEGIN RSA PRIVATE KEY-----")
      check_message_printed("-----END RSA PRIVATE KEY-----")
    end

    it "includes the public key" do
      check_message_printed("-----BEGIN PUBLIC KEY-----")
      check_message_printed("-----END PUBLIC KEY-----")
    end

    it "includes a reference to the documentation guide" do
      check_message_printed("docs/services/bulletin_board.md")
    end
  end
end
