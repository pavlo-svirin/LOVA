Ext.define('Loto.model.Game', {
  extend: 'Ext.data.Model',
  fields: [
    {name: 'id', type: 'int'},
    {name: 'date', type: 'date', dateFormat: 'Y-m-d H:i:s'},
    {name: 'lucky_numbers', type: 'string'},
    {name: 'tickets', type: 'int'},
    {name: 'users', type: 'int'},
    {name: 'sum'}
  ]
});
