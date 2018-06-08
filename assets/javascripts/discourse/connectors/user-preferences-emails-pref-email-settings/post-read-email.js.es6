export default {
  setupComponent(args, component) {
    if (args.model.get('custom_fields.mark_post_as_read_on_email') == 'false') {
      args.model.set('custom_fields.mark_post_as_read_on_email', false)
    }
  }
}
