class OfflineCancellationMailerPreview < ActionMailer::Preview

  def offline_cancellation
    OfflineCancellationMailer.send_notification(Reservation.user.last)
  end

end
