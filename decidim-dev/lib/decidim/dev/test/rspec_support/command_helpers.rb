# frozen_string_literal: true

module Decidim
  module CommandHelpers
    #   stub_command_broadcast(Decidim::Admin::DestroyTaxonomy, :invalid)
    def stub_command_broadcast(command_class, event, *)
      allow(command_class).to receive(:new).and_wrap_original do |original, *args, **kwargs|
        original.call(*args, **kwargs).tap do |command|
          allow(command).to receive(:call) { command.send(:broadcast, event, *) }
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.include Decidim::CommandHelpers
end
