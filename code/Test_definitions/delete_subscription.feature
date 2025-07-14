Feature: Delete SMS Delivery Notification Subscription

  Background: Common setup
    Given an environment at "apiRoot"
    And the resource "/subscriptions/{subscriptionId}"
    And the header "Authorization" is set to a valid access token
    And the header "x-correlator" complies with the schema at "#/components/parameters/x-correlator"

  @sms_subscribe_delete_01_success
  Scenario: Delete an existing subscription
    Given a valid subscriptionId exists
    When the request "DeleteSubscription" is sent with that subscriptionId
    Then the response status code is 204

  @sms_subscribe_delete_02_invalid
  Scenario: Delete non-existent subscription
    Given a non-existent subscriptionId
    When the request "DeleteSubscription" is sent with that subscriptionId
    Then the response status code is 404
    And the response property "$.code" is "NOT_FOUND"
