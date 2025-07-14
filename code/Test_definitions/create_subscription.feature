Feature: Create SMS Delivery Notification Subscription

  Background: Common setup
    Given an environment at "apiRoot"
    And the resource "/subscriptions"
    And the header "Content-Type" is set to "application/json"
    And the header "Authorization" is set to a valid access token
    And the header "x-correlator" complies with the schema at "#/components/parameters/x-correlator"
    And the request body is set to a valid "#/components/schemas/CreateSubscription" schema

  @sms_subscribe_create_01_success
  Scenario: Successfully create a subscription
    Given the request body property "$.subscriptionDetail.senderId" is set to a valid senderId
    And the request body property "$.subscriptionDetail.type" is set to "org.camaraproject.sms.v0.sms-delivery-status"
    And the request body property "$.webhook.notificationUrl" is set to a valid callback URL
    When the request "CreateSMSDeliverySubscription" is sent
    Then the response status code is 201
    And the response body complies with the OAS schema at "/components/schemas/SubscriptionInfo"
    And the response property "$.subscriptionId" exists

  @sms_subscribe_create_02_no_auth
  Scenario: Missing authentication
    Given the header "Authorization" is not sent
    When the request "CreateSMSDeliverySubscription" is sent
    Then the response status code is 401
    And the response property "$.code" is "UNAUTHENTICATED"

  @sms_subscribe_create_03_invalid_sender
  Scenario: Invalid senderId
    Given the request body property "$.subscriptionDetail.senderId" is set to "invalid_sender"
    When the request "CreateSMSDeliverySubscription" is sent
    Then the response status code is 400
    And the response property "$.code" is "INVALID_ARGUMENT"

  @sms_subscribe_create_04_conflict
  Scenario: Create duplicate subscription
    Given a subscription already exists for the same senderId and webhook
    When the request "CreateSMSDeliverySubscription" is sent again
    Then the response status code is 409
    And the response property "$.code" is "CONFLICT"
