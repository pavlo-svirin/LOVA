Ext.define('Loto.store.Games', {
    extend: 'Ext.data.Store', 
    model: 'Loto.model.Game',
    autoLoad: false,
    pageSize: 50,
    remoteSort: true,
    proxy: new Ext.data.HttpProxy({
        type: 'jsonp',
    	url: '/admin/game/load/ajax/',
    	simpleSortMode: true,
        reader: {
            totalProperty: 'total',        	
            root: 'data'
        }
    }),
    sorters: [{
        property: 'id',
        direction: 'DESC'
    }]
});