Feature: SMS Delivery Notification Callbacks

  Background: Setup for callback testing
    Given a subscription exists with a valid senderId and callback URL

  @sms_notification_01_delivery
  Scenario: Receive delivery status notification
    When an SMS delivery event is triggered for the subscribed senderId
    Then a notification is received at the callback URL
    And the notification body complies with the OAS schema at "/components/schemas/CloudEvent"
    And the notification property "$.type" is "org.camaraproject.sms.v0.sms-delivery-status"

  @sms_notification_02_subscription_end
  Scenario: Receive subscription end notification
    Given the subscription is configured with a limited expiration or max events
    When the limit or expiration is reached
    Then a "subscription-ends" notification is received
    And the notification body complies with the OAS schema at "/components/schemas/CloudEvent"
    And subsequent queries return 404 for the subscriptionId
