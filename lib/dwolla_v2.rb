require "base64"
require "uri"
require "json"
require "forwardable"

require "faraday"
require "faraday_middleware"

require "dwolla_v2/version"
require "dwolla_v2/client"
require "dwolla_v2/portal"
require "dwolla_v2/auth"
require "dwolla_v2/token"
require "dwolla_v2/response"
require "dwolla_v2/error"
require "dwolla_v2/util"

require "dwolla_v2/middleware/symbolize_response_body"
require "dwolla_v2/middleware/handle_errors"

# OAuth errors https://tools.ietf.org/html/rfc6749
require "dwolla_v2/errors/invalid_request_error"
require "dwolla_v2/errors/invalid_client_error"
require "dwolla_v2/errors/invalid_grant_error"
require "dwolla_v2/errors/invalid_scope_error"
require "dwolla_v2/errors/unauthorized_client_error"
require "dwolla_v2/errors/access_denied_error"
require "dwolla_v2/errors/unsupported_response_type_error"
require "dwolla_v2/errors/server_error"
require "dwolla_v2/errors/temporarily_unavailable_error"
require "dwolla_v2/errors/unsupported_grant_type_error"

# Dwolla errors https://docsv2.dwolla.com/#errors
require "dwolla_v2/errors/bad_request_error"
require "dwolla_v2/errors/validation_error"
require "dwolla_v2/errors/invalid_credentials_error"
require "dwolla_v2/errors/invalid_access_token_error"
require "dwolla_v2/errors/expired_access_token_error"
require "dwolla_v2/errors/invalid_account_status_error"
require "dwolla_v2/errors/invalid_application_status_error"
require "dwolla_v2/errors/invalid_scopes_error"
require "dwolla_v2/errors/forbidden_error"
require "dwolla_v2/errors/invalid_resource_state_error"
require "dwolla_v2/errors/not_found_error"
require "dwolla_v2/errors/method_not_allowed_error"
require "dwolla_v2/errors/invalid_version_error"
require "dwolla_v2/errors/request_timeout_error"

module DwollaV2
end