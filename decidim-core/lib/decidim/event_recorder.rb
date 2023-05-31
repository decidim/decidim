# frozen_string_literal: true

# Copyright (c) 2016 Andy Pike - The MIT license
#
# This file has been copied from https://github.com/andypike/rectify/blob/master/lib/rectify/command.rb
# We have done this so we can decouple Decidim from any Virtus dependency, which is a dead project
# Please follow Decidim discussion to understand more https://github.com/decidim/decidim/discussions/7234
module Decidim
  class EventRecorder
    attr_reader :events

    def initialize
      @events = {}
    end

    def method_missing(method_name, *args, &)
      args = args.first if args.size == 1
      @events[method_name] = args
    end

    def respond_to_missing?(_method_name, _include_private = false)
      true
    end
  end
end
