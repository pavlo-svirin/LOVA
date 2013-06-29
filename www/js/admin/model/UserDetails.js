Ext.define('Loto.model.UserDetails', {
  extend: 'Ext.data.Model',
  fields: [
    {name: 'id', type: 'int'},
    {name: 'first_name', type: 'string'},
    {name: 'last_name', type: 'string'},
    {name: 'login', type: 'string'},
    {name: 'email', type: 'email'},
    {name: 'referal', type: 'string'},
    {name: 'created', type: 'date', dateFormat: 'Y-m-d H:i:s'},
    {name: 'last_seen', type: 'date', dateFormat: 'Y-m-d H:i:s'},
    {name: 'profile.country', type: 'string'},
    {name: 'profile.phone', type: 'string'},
    {name: 'profile.skype', type: 'string'},
    {name: 'profile.like', type: 'boolean'},
    {name: 'profile.validateEmail', type: 'boolean'},
    {name: 'profile.subscribe', type: 'boolean'},
    {name: 'account.personal'},
    {name: 'account.fond'},
    {name: 'account.referal'},
  ]
});
