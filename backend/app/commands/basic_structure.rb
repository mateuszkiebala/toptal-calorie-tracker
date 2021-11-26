require 'active_model'

class BasicStructure
  include ActiveModel::Model

  attr_reader :result, :status

  def initialize(params)
    super(params)
    @succeeded = false
    @status = :bad_request
    @result = {}
    @called = false
    @api_errors = []
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
    append_model_errors(self)
    ApiError.serialize(@api_errors)
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
    model&.errors&.messages&.try(:each) do |attribute, msg|
      add_error(attribute: attribute, msg: msg)
    end
  end

  def add_error(attribute:, msg:)
    api_error = ApiError.new(source: attribute, details: msg)
    @api_errors.push(api_error)
    Rails.logger.warn msg
  end
end
