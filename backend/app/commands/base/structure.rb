require 'active_model'

module Base
  class Structure
    include ActiveModel::Model

    attr_reader :result, :status

    def initialize(params)
      super(params)
      @status = :bad_request
      @called = false
      @api_errors = nil
    end

    def call
      return self if @called
      @called = true
      yield if block_given?
      execute
      self
    end

    def set_result(result, status = :ok)
      @result = result
      @status = status
    end

    def success?
      no_errors? && errors.blank?
    end

    def no_errors?
      get_errors.blank?
    end

    def set_errors(errs, status = :unprocessable_entity)
      @api_errors = errs
      @status = status
    end

    def get_errors
      @api_errors
    end

    protected

    attr_accessor :called

    def execute
      raise NotImplementedError.new('Execute method not implemented.')
    end
  end
end
