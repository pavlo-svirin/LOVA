Ext.define('Loto.store.Budget', {
    extend: 'Ext.data.Store', 
    model: 'Loto.model.Budget',
    autoLoad: false,
    pageSize: 50,
    remoteSort: true,
    proxy: new Ext.data.HttpProxy({
        type: 'jsonp',
    	url: '/admin/budget/load/ajax/',
    	simpleSortMode: true,
        reader: {
            root: 'data'
        }
    }),
    sorters: [{
        property: 'game_id',
        direction: 'DESC'
    }]
});