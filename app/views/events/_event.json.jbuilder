event = @event if event.nil?
json.extract! event,
    :details,
    :name,
    :created_at,
    :updated_at,
    :local_time,
    :local_date,
    :tv_time,
    :is_all_day,
    :time_format,
    :description,
    :width,
    :height,
    :crop_x,
    :crop_y,
    :user,
    :country,
    :location_type,
    :subkast,
    :comment_count
json.set! '_id', event._id.to_s
json.set! :datetime, event.datetime.utc if event.datetime != nil
json.set! :mediumUrl, event.image.url(:medium)
json.set! :thumbUrl, event.image.url(:thumb)
json.set! :originalUrl, event.image.url(:original)
json.set! :upvote_allowed, user_signed_in?
if user_signed_in?
  json.set! :have_i_upvoted, event.upvoted?(current_user)
end
json.set! :upvotes, event.how_many_upvotes()
