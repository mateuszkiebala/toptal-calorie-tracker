module Common
  class Base < BasicStructure

    FIELDS = [:current_user].freeze
    attr_accessor *FIELDS

    def initialize(params)
      raise ArgumentError.new("Missing current_user") if params[:current_user].blank?
      super(params)
    end
  end
end
