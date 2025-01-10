# frozen_string_literal: true

require 'net/http/spy'

module Net
  class HTTP
    module Spy
      module Prepend
        include Net::HTTP::Spy

        def initialize(*, &)
          pre_initialize(*)
          super
          post_initialize
        end

        def request(*, &)
          pre_request(*)
          result = super
          post_request(result, *)

          result
        end
      end
    end
  end
end

Net::HTTP.prepend Net::HTTP::Spy::Prepend
Net::HTTP.http_logger = Logger.new(STDOUT)
