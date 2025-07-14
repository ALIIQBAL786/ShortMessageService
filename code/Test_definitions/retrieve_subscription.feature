Feature: Retrieve SMS Delivery Notification Subscriptions

  Background: Common setup
    Given an environment at "apiRoot"
    And the resource "/subscriptions"
    And the header "Authorization" is set to a valid access token
    And the header "x-correlator" complies with the schema at "#/components/parameters/x-correlator"

  @sms_subscribe_retrieve_01_list
  Scenario: Retrieve all subscriptions
    When the request "RetrieveSubscriptionList" is sent
    Then the response status code is 200
    And the response body complies with the OAS schema at "/components/schemas/SubscriptionInfo"
    And the response is an array

  @sms_subscribe_retrieve_02_one
  Scenario: Retrieve a specific subscription by ID
    Given a valid subscriptionId exists
    When the request "RetrieveSubscription" is sent with that subscriptionId
    Then the response status code is 200
    And the response body complies with the OAS schema at "/components/schemas/SubscriptionInfo"

  @sms_subscribe_retrieve_03_invalid
  Scenario: Retrieve non-existent subscription
    Given a non-existent subscriptionId
    When the request "RetrieveSubscription" is sent with that subscriptionId
    Then the response status code is 404
    And the response property "$.code" is "NOT_FOUND"
