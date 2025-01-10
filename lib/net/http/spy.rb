# frozen_string_literal: true

require 'net/https'
require 'logger'
require 'cgi'

module Net
  class HTTP
    class << self
      attr_accessor :http_logger
      attr_accessor :http_logger_options
    end

    module Spy
      def pre_initialize(*args)
        self.class.http_logger_options ||= {}
        self.class.http_logger_options = defaults if self.class.http_logger_options == :default

        @logger_options = default_options.merge self.class.http_logger_options
        @params_limit = @logger_options[:params_limit] || @logger_options[:limit]
        @body_limit = @logger_options[:body_limit] || @logger_options[:limit]

        self.class.http_logger.info "CONNECT: #{args.inspect}" if !@logger_options[:verbose]
      end

      def post_initialize
        @debug_output = self.class.http_logger if @logger_options[:verbose]
      end

      def pre_request(*args)
        unless started? || @logger_options[:verbose]
          req = args[0].class::METHOD
          self.class.http_logger.info "#{req} #{args[0].path}"
        end
      end

      def post_request(result, *args)
        return if started? || @logger_options[:verbose]

        if args[0].body && req != 'CONNECT'
          params = CGI.parse(args[0].body)
          self.class.http_logger.info "PARAMS #{params.inspect[0..@params_limit]} "
        end

        self.class.http_logger.info "TRACE: #{caller.reverse}" if @logger_options[:verbose]

        body = @logger_options[:body] ? result.body : result.class.name
        self.class.http_logger.info "BODY: #{body[0..@body_limit]}"
      end

      private

      def default_options
        { body: false, trace: false, verbose: false, limit: -1 }
      end
    end
  end
end
