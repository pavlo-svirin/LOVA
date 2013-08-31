Ext.define('Loto.model.Budget', {
  extend: 'Ext.data.Model',
  fields: [
    { name: 'game_id', type: 'int' },
    { name: 'sum', type: 'float' },
    { name: 'prize', type: 'float' },
    { name: 'fond', type: 'float' },
    { name: 'gift', type: 'float' },
    { name: 'bonus', type: 'float' },
    { name: 'costs', type: 'float' },
    { name: 'profit', type: 'float' },
    { name: 'total', type: 'float' }
  ]
});
