export default {
  shouldRender(args, component) {
    return Discourse.SiteSettings.post_read_email_enabled
  },

  setupComponent(args, component) {
    if (args.model.get('custom_fields.mark_post_as_read_on_email') == 'f' ||
        args.model.get('custom_fields.mark_post_as_read_on_email') == 'false') {
      args.model.set('custom_fields.mark_post_as_read_on_email', false)
    }
  }
}
