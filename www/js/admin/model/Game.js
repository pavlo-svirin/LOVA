Ext.define('Loto.model.Game', {
  extend: 'Ext.data.Model',
  requires: [ 'Loto.model.Ticket' ],
  fields: [
    { name: 'id', type: 'int'},
    { name: 'date', type: 'date', dateFormat: 'Y-m-d H:i:s'},
    { name: 'lucky_numbers', type: 'string'},
    { name: 'lova_number', type: 'string'},
    { name: 'tickets', type: 'int'},
    { name: 'users', type: 'int'},
    { name: 'sum'},
    { name: 'approved', type: 'date', dateFormat: 'Y-m-d H:i:s'},
    { name: 'winners', type: 'string'},
    { name: 'budget.sum' },
    { name: 'budget.prize' },
    { name: 'budget.fond' },
    { name: 'budget.gift' },
    { name: 'budget.bonus' },
    { name: 'budget.costs' },
    { name: 'budget.profit' }
  ],
  hasMany:[
    {
       foreignKey: 'game_id',
       associationKey: 'winner_tickets',
       name: 'winner_tickets',
       model: 'Loto.model.Ticket'
    }
  ]  
});
