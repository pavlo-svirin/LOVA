Ext.define('Loto.model.Game', {
  extend: 'Ext.data.Model',
  fields: [
    { name: 'id', type: 'int'},
    { name: 'date', type: 'date', dateFormat: 'Y-m-d H:i:s'},
    { name: 'lucky_numbers', type: 'string'},
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
  ]
});