class ApplicationController < ActionController::API
  include ApiError

  before_action :authenticate_request
  skip_before_action :authenticate_request, only: [:route_not_found]
  before_action :parse_body

  def route_not_found
    logger.error("Endpoint not found (#{params})")
    raise RouteNotFoundError, "Endpoint not found"
  end

  protected

  def authenticate_request
    @current_user = AuthenticateApiRequest.new(request.headers).call.result
    raise AuthenticationError, "Not Authenticated." if @current_user.blank?
  end

  def handle_bad_request(ex)
    if Rails.env.production? || Rails.env.test?
      logger.error("Received a bad request (#{ex.message})")
      render_error("Internal server error", :internal_server_error)
    else
      raise ex
    end
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

    def handle_command(command_model, data, success_status, error_status = :bad_request)
      command = command_model.new(data).call
      if command.success?
        render_success(command.result, success_status)
      else
        render_error(command.get_errors.dig(:messages), error_status)
      end
    end
  end
end
