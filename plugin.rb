# name: post-read-email
# about: A plugin to give users the option of making posts as read when emailed
# version: 0.0.1
# authors: Leo McArdle
# url: https://github.com/mozilla/discourse-post-read-email

DiscoursePluginRegistry.serialized_current_user_fields << 'mark_post_as_read_on_email'

module JobsUserEmailExtensions
  def message_for_email(user, post, type, notification, args = nil)
    message, skip_reason = super
    if message && user.custom_fields['mark_post_as_read_on_email'] == 'true'
      notification.update(read: true)
      TopicUser.update_last_read(user, post.topic&.id, post.post_number, 0, 0)
    end
    [message, skip_reason]
  end
end

after_initialize do
  Jobs::UserEmail.prepend JobsUserEmailExtensions
end
