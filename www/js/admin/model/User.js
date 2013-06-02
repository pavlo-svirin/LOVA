Ext.define('Loto.model.User', {
  extend: 'Ext.data.Model',
  fields: [
    {name: 'id', type: 'int'},
    {name: 'first_name', type: 'string'},
    {name: 'last_name', type: 'string'},
    {name: 'login', type: 'string'},
    {name: 'email', type: 'email'},
    {name: 'referal', type: 'string'},
    {name: 'created', type: 'date', dateFormat: 'Y-m-d H:i:s'},
    {name: 'last_seen', type: 'date', dateFormat: 'Y-m-d H:i:s'}
  ],
  autoLoad: true,
});
