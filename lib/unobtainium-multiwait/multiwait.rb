# coding: utf-8
#
# unobtainium-multiwait
# https://github.com/jfinkhaeuser/unobtainium-multiwait
#
# Copyright (c) 2016 Jens Finkhaeuser and other unobtainium-multiwait contributors.
# All rights reserved.
#

require 'unobtainium'
require 'unobtainium-multifind'

module Unobtainium
  module MultiWait
    ##
    # Driver module implementing multi wait functionality.
    module DriverModule
      ##
      # Default options. This hash is also used to detect if any of the Hashes
      # passed to #multiwait is an options Hash; it is considered one if it
      # contains any of the keys specified here.
      DEFAULT_OPTIONS = {
        # If true, raises on error instead of returning nil
        raise_on_error: false,
        # If true, returns the error object instead of nil
        return_errors: false,
        # If :all is specified, the method waits for all elements to
        #   appear or times out.
        # If :first is specified, the method returns when the first
        #   element appears.
        wait_for: :all,
        # Defaults to only finding :displayed? elements. You can use any method
        # that Selenium::WebDriver::Element responds to, or :exists? if you only
        # care whether the element exists.
        check_element: :displayed?,
        # The default wait timeout in seconds.
        timeout: 10,
      }.freeze

      class << self
        ##
        # Returns true if the implementation has `#find_element`, false
        # otherwise.
        def matches?(impl)
          return impl.respond_to?(:find_element)
        end
      end # class << self

      ##
      # Current options for multiwait
      attr_accessor :multiwait_options
      @multiwait_options = DEFAULT_OPTIONS

      ##
      # Wait for multiple elements. Each argument is a Hash of selector options
      # that are passed to #find_element. If one argument contains keys from
      # the DEFAULT_OPTIONS Hash, it is instead treated as an options Hash for
      # the #multiwait method.
      # @return Array of found elements or nil entries if no matching element
      #   was found.
      #   FIXME: recheck this!
      def multiwait(*args)
        # Parse options
        options, selectors = multiwait_parse_options(*args)

        # Pass some options to multifind
        multifind_opts = {
          raise_on_error: options[:raise_on_error],
          return_errors: options[:return_error],
          check_element: options[:check_element],
        }

        # Wait for elements
        results = []
        wait = ::Selenium::WebDriver::Wait.new(timeout: options[:timeout])
        begin
          wait.until do
            results = multifind(*selectors, multifind_opts)
            got_it, results = multiwait_filter_results(options, results)
            if got_it
              return results
            end
          end
        rescue ::Selenium::WebDriver::Error::TimeOutError => err
          if options[:raise_on_error]
            raise
          end
          if options[:return_errors]
            results.map! { |result| result.nil? ? err : result }
          end
        end

        return results
      end

      alias wait multiwait

      private

      def multiwait_filter_results(options, results)
        if options[:wait_for] != :first
          got_it = true
          results.each do |result|
            # rubocop:disable Style/Next
            if result.nil? or
               result.is_a?(::Selenium::WebDriver::Error::NoSuchElementError)
              got_it = false
              break
            end
            # rubocop:enable Style/Next
          end
          return got_it, results
        end

        # If we want to exit on the first found result, we'll have to go and
        # find non-error results here.
        results.each do |result|
          if not result.nil? and
             not result.is_a?(::Selenium::WebDriver::Error::NoSuchElementError)
            return true, [result]
          end
        end

        return false, []
      end

      ##
      # Distinguishes between option hashes and selectors by detecting Hash
      # arguments with keys from DEFAULT_OPTIONS. Those are considered to be
      # options, and merged with any preceding option hashes, where latter
      # occurrences overwrite earlier ones.
      def multiwait_parse_options(*args)
        # Sanity
        if @multiwait_options.nil?
          @multiwait_options = DEFAULT_OPTIONS
        end

        # Distinguish between options and selectors
        options = {}
        selectors = []
        args.each do |arg|
          # Let the underlying API handle all non-Hashes
          if not arg.is_a?(Hash)
            selectors << arg
            next
          end

          # See if it contains any of the keys we care about
          option_keys = DEFAULT_OPTIONS.keys
          diff = option_keys - arg.keys
          if diff != option_keys
            options.merge!(arg)
            next
          end

          selectors << arg
        end
        options = @multiwait_options.merge(options)
        options = DEFAULT_OPTIONS.merge(options)

        # Ensure that the 'wait_for' option contains correct
        # values only.
        if not [:all, :first].include?(options[:wait_for])
          raise ArgumentError, ":wait_for option must be either :all or :first, "\
            "but is: #{options[:wait_for]}"
        end

        # Ensure that 'check_element' contains only valid options.
        elem_klass = ::Selenium::WebDriver::Element
        if options[:check_element] != :exists? and
           not elem_klass.instance_methods.include?(options[:check_element])
          raise ArgumentError, ":check_element must either be :exists? or "\
            "a boolean method that ::Selenium::WebDriver::Element responds to, "\
            "but got: #{options[:check_element]}"
        end

        return options, selectors
      end

    end # module DriverModule
  end # module MultiWait
end # module Unobtainium

::Unobtainium::Driver.register_module(
    ::Unobtainium::MultiWait::DriverModule,
    __FILE__)
