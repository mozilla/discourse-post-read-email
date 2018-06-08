import { withPluginApi } from 'discourse/lib/plugin-api'

export default {
  name: 'post-read-email',
  initialize () {
     withPluginApi('0.8.22', api => {

       api.modifyClass('controller:preferences/emails', {
         actions: {
           save () {
             this.saveAttrNames.push('custom_fields')
             this._super()
           }
         }
       })

     })
  }
}
