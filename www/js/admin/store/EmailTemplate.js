Ext.define('Loto.store.EmailTemplate', {
    extend: 'Ext.data.Store', 
    model: 'Loto.model.EmailTemplate',
    autoLoad: true,
    proxy: new Ext.data.HttpProxy({
        type: 'jsonp',
    	url: '/admin/emailTemplate/load/ajax/',
        reader: {
            root: 'data'
        }
    })
});