module ApiError
  extend ActiveSupport::Concern

  included do
    class AuthorizationError < StandardError; end
    class RouteNotFoundError < StandardError; end

    rescue_from Exception, :with => :handle_bad_request
    rescue_from StandardError, :with => :handle_bad_request
    rescue_from AuthorizationError, :with => :handle_authorization_error
    rescue_from RouteNotFoundError, :with => :handle_route_not_found_error
    rescue_from JSON::ParserError, :with => :handle_json_parser_error
    rescue_from ActionController::ParameterMissing, with: :handle_bad_request
    rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :handle_not_found

    def handle_bad_request(e)
      render_error(e.message, :bad_request)
    end

    def handle_authorization_error(e)
      render_error("Not Authorized", :unauthorized)
    end

    def handle_route_not_found_error(e)
      render_error("Endpoint not found", :not_found)
    end

    def handle_json_parser_error(e)
      render_error("Invalid JSON -> #{e}", :bad_request)
    end

    def handle_not_found(e)
      render_error(e.message, :not_found)
    end

    def render_error(message, status)
      render json: { error: { messages: message } }, status: status
    end

    def render_success(data = {}, status)
      render json: data, status: status
    end
  end
end
