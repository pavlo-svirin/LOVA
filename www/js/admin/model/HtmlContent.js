Ext.define('Loto.model.HtmlContent', {
  extend: 'Ext.data.Model',
  fields: [
    {name: 'id', type: 'int'},
    {name: 'code', type: 'string'},
    {name: 'lang', type: 'string'},
    {name: 'content', type: 'string'}
  ],
  autoLoad: true,
});
