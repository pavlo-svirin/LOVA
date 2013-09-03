Ext.define('Loto.store.Tickets', {
    extend: 'Ext.data.Store', 
    model: 'Loto.model.Ticket',
    autoLoad: false,
    pageSize: 50,
    remoteSort: true,
    proxy: new Ext.data.HttpProxy({
        type: 'jsonp',
    	url: '/admin/tickets/list/ajax/',
        reader: {
            root: 'data'
        }
    })
});