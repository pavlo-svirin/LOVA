Ext.define('Loto.model.Ticket', {
  extend: 'Ext.data.Model',
  fields: [
    {name: 'id', type: 'int'},
    {name: 'user_id', type: 'int'},
    {name: 'numbers', type: 'string'},
    {name: 'lova_number', type: 'string'},
    {name: 'games', type: 'int'},
    {name: 'games_left', type: 'int'},
    {name: 'created', type: 'date', dateFormat: 'Y-m-d H:i:s'},
    {name: 'paid', type: 'date', dateFormat: 'Y-m-d H:i:s'},
    {name: 'game_price'},
    {name: 'total'},
  ]
});
