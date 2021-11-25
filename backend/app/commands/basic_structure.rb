require 'active_model'

class BasicStructure
  include ActiveModel::Model

  attr_reader :result

  def initialize(params)
    super(params)
    @succeeded = false
    @result = {}
    @called = false
    @error_codes = []
  end

  def call
    return self if @called
    @called = true
    yield if block_given?
    execute
    self
  end

  def no_errors?
    get_errors.blank?
  end

  def get_errors
    {
      messages: errors.full_messages,
      codes: @error_codes.uniq
    }.delete_if { |k, v| v.blank? } || {}
  end

  def success?
    (@succeeded && no_errors?) || false
  end

  protected

  attr_accessor :called

  def execute
    raise NotImplementedError.new('Execute method not implemented.')
  end

  def append_model_errors(model)
    model&.errors&.try(:each) do |k, v|
      errors.add(k, v)
    end
  end

  def append_command_errors(command)
    unless command.success?
      errs = command.get_errors
      errs.dig(:messages).each { |msg| errors.add(:base, msg) }
      @error_codes += errs.dig(:codes)
    end
  end

  def add_error(msg:, code:, field: :base)
    errors.add(field, msg)
    @error_codes << code
    Rails.logger.warn msg
  end
end
