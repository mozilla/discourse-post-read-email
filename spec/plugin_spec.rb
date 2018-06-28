require "rails_helper"

describe UserSerializer do
  let(:user) { Fabricate(:user) }
  let(:json) { UserSerializer.new(user, scope: Guardian.new(user), root: false).as_json }

  it "should contain mark_post_as_read_on_email field" do
    user.custom_fields["mark_post_as_read_on_email"] = "true"
    user.save_custom_fields
    expect(json[:custom_fields]["mark_post_as_read_on_email"]).to eq("true")
  end

end

describe "EmailSenderExtensions" do
  before do
    NotificationEmailer.enable
    SiteSetting.queue_jobs = false
  end

  let(:user) { Fabricate(:user) }
  let(:post) { Fabricate(:post) }
  let(:pm_post) do
    PostCreator.create(Fabricate(:user), title: "private message test",
                                         raw: "this is my private message",
                                         archetype: Archetype.private_message,
                                         target_usernames: user.username)
  end

  before do
    TopicUser.change(user.id, post.topic.id, notification_level: TopicUser.notification_levels[:watching])
  end

  shared_examples "leaves unread" do
    it "leaves post unread" do
      PostAlerter.post_created(post)
      expect(Notification.where(user: user, topic: post.topic, post_number: post.post_number).first.read).to eq(false)
    end

    it "leaves pm unread" do
      PostAlerter.post_created(pm_post)
      expect(Notification.where(user: user, topic: pm_post.topic, post_number: pm_post.post_number).first.read).to eq(false)
    end
  end

  shared_examples "marks read" do
    it "marks post as read" do
      PostAlerter.post_created(post)
      expect(Notification.where(user: user, topic: post.topic, post_number: post.post_number).first.read).to eq(true)
    end

    it "marks pm as read" do
      PostAlerter.post_created(pm_post)
      expect(Notification.where(user: user, topic: pm_post.topic, post_number: pm_post.post_number).first.read).to eq(true)
    end
  end

  context "when notification email succeeds" do

    shared_examples "sends email" do
      it "sends post notification" do
        PostAlerter.post_created(post)
        expect(EmailLog.where(user: user, post: post, skipped: false, email_type: "user_posted").count).to eq(1)
      end

      it "sends pm notification" do
        PostAlerter.post_created(pm_post)
        expect(EmailLog.where(user: user, post: pm_post, skipped: false, email_type: "user_private_message").count).to eq(1)
      end
    end

    context "when mark_post_as_read_on_email is unset" do
      include_examples "sends email"
      include_examples "leaves unread"
    end

    context "when mark_post_as_read_on_email is 'false'" do
      before do
        user.custom_fields["mark_post_as_read_on_email"] = "false"
        user.save_custom_fields
      end

      include_examples "sends email"
      include_examples "leaves unread"
    end

    context "when mark_post_as_read_on_email is false" do
      before do
        user.custom_fields["mark_post_as_read_on_email"] = false
        user.save_custom_fields
      end

      include_examples "sends email"
      include_examples "leaves unread"
    end

    context "when mark_post_as_read_on_email is 'true'" do
      before do
        user.custom_fields["mark_post_as_read_on_email"] = "true"
        user.save_custom_fields
      end

      include_examples "sends email"
      include_examples "marks read"
    end

    context "when mark_post_as_read_on_email is true" do
      before do
        user.custom_fields["mark_post_as_read_on_email"] = true
        user.save_custom_fields
      end

      include_examples "sends email"
      include_examples "marks read"
    end
  end

  context "when notification email fails" do
    before do
      ActionMailer::MessageDelivery.any_instance.expects(:deliver_now).once.raises(Net::SMTPFatalError)
    end

    shared_examples "skips email" do
      it "skips post notification" do
        PostAlerter.post_created(post)
        expect(EmailLog.where(user: user, post: post, skipped: false, email_type: "user_posted").count).to eq(0)
        expect(EmailLog.where(user: user, skipped: true, email_type: "user_posted").count).to eq(1)
      end

      it "skips pm notification" do
        PostAlerter.post_created(pm_post)
        expect(EmailLog.where(user: user, post: pm_post, skipped: false, email_type: "user_private_message").count).to eq(0)
        expect(EmailLog.where(user: user, skipped: true, email_type: "user_private_message").count).to eq(1)
      end

      include_examples "leaves unread"
    end

    context "when mark_post_as_read_on_email is unset" do
      include_examples "skips email"
    end

    context "when mark_post_as_read_on_email is 'false'" do
      before do
        user.custom_fields["mark_post_as_read_on_email"] = "false"
        user.save_custom_fields
      end

      include_examples "skips email"
    end

    context "when mark_post_as_read_on_email is false" do
      before do
        user.custom_fields["mark_post_as_read_on_email"] = false
        user.save_custom_fields
      end

      include_examples "skips email"
    end

    context "when mark_post_as_read_on_email is 'true'" do
      before do
        user.custom_fields["mark_post_as_read_on_email"] = "true"
        user.save_custom_fields
      end

      include_examples "skips email"
    end

    context "when mark_post_as_read_on_email is true" do
      before do
        user.custom_fields["mark_post_as_read_on_email"] = true
        user.save_custom_fields
      end

      include_examples "skips email"
    end
  end

end
