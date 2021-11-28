class ApplicationController < ActionController::API
  include ApiErrorHandling
  include JSONAPI::Deserialization
  include JSONAPI::Pagination
  include JSONAPI::Filtering

  before_action :authenticate_request
  skip_before_action :authenticate_request, only: [:route_not_found]
  before_action :parse_body

  def route_not_found
    logger.error("Endpoint not found (#{params})")
    raise RouteNotFoundError.new
  end

  protected

  def authenticate_request
    raise AuthenticationError.new if current_user.blank?
  end

  def authorise_admin_access
    raise AuthorisationError.new if current_user.blank? || !current_user.admin?
  end

  def current_user
    @current_user ||= AuthenticateApiRequest.new(request.headers).call
  end

  def parse_body
    if not %w'application/json text/plain'.include?(request.content_type)
      @parsed_body = {}
    elsif @has_parsed_body
      @parsed_body
    else
      body = request.body.read
      @parsed_body = body.blank? ? {} : ActionController::Parameters.new(JSON.parse(body))
      @has_parsed_body = true
      @parsed_body
    end
  end

  def handle_command(command_model, data, options={})
    command = command_model.new(data).call
    if command.success?
      render_jsonapi_success(command.result, command.status || :ok, options)
    else
      render_jsonapi_errors(command.get_errors, command.status || :bad_request, options)
    end
  end

  def render_jsonapi_index(data_source, filter_allowed)
    jsonapi_filter(data_source, filter_allowed) do |filtered|
      jsonapi_paginate(filtered.result) do |paginated|
        render jsonapi: paginated, status: :ok, meta: jsonapi_pagination_meta(paginated)
      end
    end
  end

  def render_jsonapi_success(data, status, options={})
    render jsonapi: data, status: status, **options
  end

  def render_jsonapi_errors(data, status, options={})
    render jsonapi_errors: data, status: status, **options
  end
end
