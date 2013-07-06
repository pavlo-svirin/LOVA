Ext.define('Loto.model.EmailTemplate', {
  extend: 'Ext.data.Model',
  fields: [
    {name: 'id', type: 'int'},
    {name: 'code', type: 'string'},
    {name: 'lang', type: 'string'},
    {name: 'subject', type: 'string'},
    {name: 'body', type: 'string'}
  ],
  autoLoad: true,
});
