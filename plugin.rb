# name: post-read-email
# about: A plugin to give users the option of marking posts as read when emailed
# version: 0.0.8
# authors: Leo McArdle
# url: https://github.com/mozilla/discourse-post-read-email

enabled_site_setting :post_read_email_enabled

after_initialize do
  register_editable_user_custom_field :mark_post_as_read_on_email
end

require_relative "plugin_code"
