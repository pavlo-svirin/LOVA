Ext.define('Loto.store.User', {
    extend: 'Ext.data.Store', 
    model: 'Loto.model.User',
    pageSize: 500,
    remoteSort: true,
    autoLoad: true,
    proxy: new Ext.data.HttpProxy({
        type: 'jsonp',
        url: '/admin/users/load/ajax/',
        simpleSortMode: true,
        reader: {
            totalProperty: 'total',
            root: 'data'
        }
    }),
    sorters: [{
        property: 'created',
        direction: 'DESC'
    }]
});