# frozen_string_literal: true

require_relative '../lib/typeguard/validator'

# rubocop:disable all

class Example
  # The argument order is swapped, arguments are interpreted incorrectly
  # @param rhs [Integer]
  # @param lhs [String]
  # @return [String]
  def add_number_to_string(lhs, rhs)
    lhs + rhs.to_s
  end

  # @param base [Integer]
  # @param arr [Array<Integer>]
  # @return [Integer]
  def splat_arg(base, *arr)
    arr.sum(base)
  end

  # Should fail when rhs default is Float
  # @param lhs [Integer]
  # @param rhs [Integer]
  # @return [Integer]
  def optional_arg(lhs, rhs = 1)
    lhs + rhs
  end

  # @param lhs [Integer]
  # @param rhs [Integer]
  # @return [Integer]
  def keyword_arg(lhs:, rhs:)
    lhs + rhs
  end

  # @param lhs [Integer]
  # @param rhs [Integer]
  # @return [Integer]
  def keyword_optional_arg(lhs:, rhs: 1)
    lhs + rhs
  end

  # keyrest = **opts
  # opt     = opts = {}
  # @param opts [Hash] the options to create a message with.
  # @option opts [String] :subject The subject
  # @option opts [String] :from ('nobody') From address
  # @option opts [String] :to Recipient email
  # @option opts [String] :body ('') The email's body
  # @return [String]
  def kwargs_arg(**opts)
    opts.entries.join '='
  end

  # @param other [Integer]
  # @param other2 [Integer]
  # @param lhs [Integer]
  # @param rhs [Integer]
  # @param opts [Hash] the options to create a message with.
  # @option opts [Integer] :a
  # @option opts [Integer] :b
  # @option opts [Integer] :c
  # @option opts [Integer] :d
  # @return [Integer]
  def mixed_keyword_arg(other, other2, lhs:, rhs:, **opts)
    other + other2 + lhs + rhs + opts.values.sum
  end

  # @param opts [Hash] the options to create a message with.
  # @option opts [Integer] :b
  # @param a [Integer]
  # @return [Integer]
  def optional_hash(opts = {}, a:)
    a
  end

  # @param a [Integer]
  # @param b [Integeer]
  # @param c [Integer]
  # @param d [Integer]
  # @return [Integer]
  def simple(a, b = 3, c:, d: 1)
    a + b + c + d
  end

  protected

  ##  @param base [Integer]
  # @param arr [Array<Integer>]
  # @return [Integer]
  def self.splat_arg(base, *arr)
    arr.sum(base)
  end
end

Typeguard.configure do |config|
  config.sqlite3 = 'test.db'
  # config.source = :rbs
  # config.target = 'sig'
  config.source = :yard
  config.target = ['bin/example2.rb']
  config.enabled = true
  config.reparse = true
  config.at_exit_report = true
  config.resolution.raise_on_name_error = false
  config.wrapping.raise_on_unexpected_arity = false
  config.wrapping.raise_on_unexpected_visibility = false
  config.validation.raise_on_unexpected_argument = false
  config.validation.raise_on_unexpected_return = false
end.process!

example = Example.new
example.splat_arg(10, 1, 3)
example.optional_arg(1)
example.add_number_to_string('one', 2)
example.keyword_arg(lhs: 1, rhs: 2)
example.keyword_optional_arg(lhs: 2)
example.kwargs_arg(subject: 'subj', body: 'b')
example.mixed_keyword_arg(1, 2, lhs: 3, rhs: 4, a: 1, b: 2, c: 3, d: 4)
example.optional_hash(Hash[b: 1], a: 1)
example.optional_hash({}, a: 1)
Example.splat_arg(10, 1, 3.0)
