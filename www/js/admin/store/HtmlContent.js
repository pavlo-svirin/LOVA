Ext.define('Loto.store.HtmlContent', {
    extend: 'Ext.data.Store', 
    model: 'Loto.model.HtmlContent',
    autoLoad: false,
    proxy: new Ext.data.HttpProxy({
        type: 'jsonp',
    	url: '/admin/htmlContent/load/ajax/',
        reader: {
            root: 'data'
        }
    })
});