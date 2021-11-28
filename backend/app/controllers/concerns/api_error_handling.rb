module ApiErrorHandling
  extend ActiveSupport::Concern

  included do
    class AuthenticationError < StandardError; end
    class AuthorisationError < StandardError; end
    class RouteNotFoundError < StandardError; end
    class ObjectNotFound < StandardError; end

    rescue_from Exception, :with => :handle_internal_server_error
    rescue_from StandardError, :with => :handle_bad_request
    rescue_from AuthenticationError, :with => :handle_authentication_error
    rescue_from AuthorisationError, :with => :handle_authorisation_error
    rescue_from ObjectNotFound, :with => :handle_not_found
    rescue_from RouteNotFoundError, :with => :handle_route_not_found_error
    rescue_from JSON::ParserError, :with => :handle_json_parser_error
    rescue_from ActionController::ParameterMissing, with: :handle_bad_request
    rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :handle_not_found

    def handle_internal_server_error(ex)
      if Rails.env.production? || Rails.env.test?
        logger.error("Received a bad request (#{ex.message})")
        render_error_from_message("Internal server error", :internal_server_error)
      else
        raise ex
      end
    end

    def handle_bad_request(e)
      render_error_from_message(e.message, :bad_request)
    end

    def handle_authentication_error(e)
      render_error_from_message("Not Authenticated", :unauthorized)
    end

    def handle_authorisation_error(e)
      render_error_from_message("Not Authorised", :forbidden)
    end

    def handle_route_not_found_error(e)
      render_error_from_message("Endpoint not found", :not_found)
    end

    def handle_json_parser_error(e)
      render_error_from_message("Invalid JSON -> #{e}", :bad_request)
    end

    def handle_not_found(e)
      render_error_from_message(e.message, :not_found)
    end

    def render_error_from_message(message, status)
      code = Rack::Utils::SYMBOL_TO_STATUS_CODE[status]
      api_error = ApiError.new(detail: message, status: code, title: Rack::Utils::HTTP_STATUS_CODES[code])
      render_error(ApiError.serialize([api_error]), status)
    end

    def render_error(error, status)
      render json: error.to_json, status: status
    end
  end
end
