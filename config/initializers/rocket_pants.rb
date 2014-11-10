RocketPants::Errors.register! :event_not_found, http_status: :unprocessable_entity
RocketPants::Errors.register! :invalid_reminder_interval, http_status: :unprocessable_entity
RocketPants::Errors.register! :reminder_already_set, http_status: :unprocessable_entity
RocketPants::Errors.register! :comment_already_upvoted, http_status: :unprocessable_entity
RocketPants::Errors.register! :comment_not_upvoted, http_status: :unprocessable_entity
RocketPants::Errors.register! :comment_not_found, http_status: :unprocessable_entity
