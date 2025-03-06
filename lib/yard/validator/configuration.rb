# frozen_string_literal: true

module Yard::Configuration
  attr_reader :enabled, :raise_on_failure, :report_on_failure, :document_untyped, :report_untyped

  @enabled = false
  @raise_on_failure = false
  @report_on_failure = false
  @document_untyped = false
  @report_untyped = false

  def enable
    @enabled = true
  end

  def enable_raise_on_failure
    @raise_on_failure = true
  end

  def enable_report_on_failure
    @report_on_failure = true
  end

  def enable_document_untyped
    @document_untyped = true
  end

  def enable_report_untyped
    @report_untyped = true
  end

  def disable
    @enabled = false
  end
end
