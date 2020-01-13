# frozen_string_literal: true

RSpec.shared_context "with stdout sniffing" do
  let!(:original_stdout) { $stdout }

  # rubocop:disable RSpec/ExpectOutput
  before do
    $stdout = StringIO.new
  end

  after do
    $stdout = original_stdout
  end
  # rubocop:enable RSpec/ExpectOutput
end

def check_no_errors_have_been_printed
  expect($stdout.string).not_to include("ERROR:")
end

def check_some_errors_have_been_printed
  expect($stdout.string).to include("ERROR:")
end

def check_error_printed(type = "File not found")
  expect($stdout.string).to include("ERROR: [#{type}]")
end

def check_message_printed(message = "RightToBeForgotten")
  expect($stdout.string).to include(message)
end
