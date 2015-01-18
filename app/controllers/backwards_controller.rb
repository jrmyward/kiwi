class BackwardsController < ApplicationController
  def by_date

  end

  def comments
    event = Event.find(params[:id])

    @comments = event.root_comments

    render 'events/comments'
  end
end
