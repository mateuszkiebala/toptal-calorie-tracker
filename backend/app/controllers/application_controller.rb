class ApplicationController < ActionController::API
  include ApiErrorHandling

  before_action :authenticate_request
  skip_before_action :authenticate_request, only: [:route_not_found]
  before_action :parse_body

  def route_not_found
    logger.error("Endpoint not found (#{params})")
    raise RouteNotFoundError, "Endpoint not found"
  end

  protected

  def authenticate_request
    @current_user = AuthenticateApiRequest.new(request.headers).call
    raise AuthenticationError, "Not Authenticated." if @current_user.blank?
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

    def handle_command(command_model, data)
      command = command_model.new(data).call
      if command.success?
        render_jsonapi_success(command.result, command.status || :ok)
      else
        render_jsonapi_errors(command.get_errors, command.status || :bad_request)
      end
    end

    #def render_index(data_source)
    def render_jsonapi_success(data = {}, status)
      render jsonapi: data, status: status
    end

    def render_jsonapi_errors(data = {}, status)
      render jsonapi_errors: data, status: status
    end
  end
end
