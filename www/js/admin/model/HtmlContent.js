Ext.define('Loto.model.HtmlContent', {
  extend: 'Ext.data.Model',
  fields: [
    {name: 'id', type: 'int'},
    {name: 'page', type: 'string'},
    {name: 'code', type: 'string'},
    {name: 'lang', type: 'string'},
    {name: 'type', type: 'string'},
    {name: 'content', type: 'string'}
  ],
  autoLoad: true,
});
