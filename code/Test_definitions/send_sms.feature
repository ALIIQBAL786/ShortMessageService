Feature: Send SMS

  # Implementation indications:
  # * apiRoot: API root of the server URL
  # * Base path: /sms/v0alpha1/short-message
  # * Uses openId token with appropriate scopes: send-sms:short-message
  #
  # Test assets:
  # * Valid recipient phone numbers
  # * Valid sender IDs
  # * Various message categories (PROMOTION, SERVICE, TRANSACTION)
  # * Valid 2-legged and 3-legged tokens as needed

  Background: Common setup
    Given an environment at "apiRoot"
    And the resource "/short-message"
    And the header "Content-Type" is set to "application/json"
    And the header "Authorization" is set to a valid access token
    And the header "x-correlator" complies with the schema at "#/components/parameters/x-correlator"
    And the request body is set by default to a valid "MessageRequest" schema

  # Success scenarios
  @sms_send_01_success_promotion
  Scenario: Send a promotional SMS to a single recipient
    Given the request body property "$.to" is set to ["+910123456789"]
    And the request body property "$.from" is set to "+919876543210"
    And the request body property "$.category" is set to "PROMOTION"
    And the request body property "$.message" is set to "Promotional message content"
    When the request "send-sms" is sent
    Then the response status code is 200
    And the response body complies with the OAS schema at "/components/schemas/MessageResponse"
    And the response property "$.msgId" exists
    And the response property "$.timestamp" matches RFC 3339 format

  @sms_send_02_success_service
  Scenario: Send a service SMS
    Given the request body property "$.category" is set to "SERVICE"
    And valid "to", "from", and "message" fields
    When the request "send-sms" is sent
    Then the response status code is 200

  @sms_send_03_success_transaction
  Scenario: Send a transaction SMS without specifying category
    Given the request body property "$.category" is set to "TRANSACTION"
    And valid "to", "from", and "message" fields
    When the request "send-sms" is sent
    Then the response status code is 200

  # Error scenarios - Authentication and authorization
  @sms_send_401.1_no_auth
  Scenario: Missing authentication
    Given the header "Authorization" is not sent
    When the request "send-sms" is sent
    Then the response status code is 401
    And the response property "$.code" is "UNAUTHENTICATED"

  @sms_send_403.1_permission_denied
  Scenario: Insufficient permission
    Given the header "Authorization" is set to an access token without "send-sms:short-message" scope
    When the request "send-sms" is sent
    Then the response status code is 403
    And the response property "$.code" is "PERMISSION_DENIED"

  # Error scenarios - Invalid inputs
  @sms_send_400.1_missing_to
  Scenario: Missing recipient address
    Given the request body property "$.to" is removed
    When the request "send-sms" is sent
    Then the response status code is 400
    And the response property "$.code" is "INVALID_ARGUMENT"

  @sms_send_400.2_missing_from
  Scenario: Missing sender ID
    Given the request body property "$.from" is removed
    When the request "send-sms" is sent
    Then the response status code is 400
    And the response property "$.code" is "INVALID_ARGUMENT"

  @sms_send_400.3_missing_message
  Scenario: Missing message body
    Given the request body property "$.message" is removed
    When the request "send-sms" is sent
    Then the response status code is 400
    And the response property "$.code" is "INVALID_ARGUMENT"

  @sms_send_400.4_invalid_category
  Scenario: Invalid category value
    Given the request body property "$.category" is set to "INVALID_CATEGORY"
    When the request "send-sms" is sent
    Then the response status code is 400
    And the response property "$.code" is "INVALID_ARGUMENT"

  # Error scenarios - Resource not found
  @sms_send_404.1_not_found
  Scenario: Endpoint not found
    Given the resource "/short-message-invalid" instead of "/short-message"
    When the request "send-sms" is sent
    Then the response status code is 404
    And the response property "$.code" is "NOT_FOUND"

  # Error scenarios - Server issues
  @sms_send_500.1_internal_server
  Scenario: Server internal error
    Given the server is configured to simulate an internal error
    When the request "send-sms" is sent
    Then the response status code is 500
    And the response property "$.code" is "INTERNAL"

  @sms_send_503.1_service_unavailable
  Scenario: Service unavailable
    Given the server is configured to simulate a maintenance window
    When the request "send-sms" is sent
    Then the response status code is 503
    And the response property "$.code" is "UNAVAILABLE"
