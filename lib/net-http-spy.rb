# frozen_string_literal: true

require 'net/http/spy'

module Net
  class HTTP
    include Net::HTTP::Spy

    alias initialize_without_spy initialize
    alias request_without_spy request

    def initialize(*, &)
      pre_initialize(*)
      initialize_without_spy(*, &)
      post_initialize
    end

    def request(*, &)
      pre_request(*)
      result = request_without_spy(*, &)
      post_request(result, *)

      result
    end
  end
end

Net::HTTP.http_logger = Logger.new(STDOUT)
