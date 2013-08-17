Ext.define('Loto.store.Games', {
    extend: 'Ext.data.Store', 
    model: 'Loto.model.Game',
    autoLoad: false,
    pageSize: 50,
    remoteSort: true,
    proxy: new Ext.data.HttpProxy({
        type: 'jsonp',
    	url: '/admin/games/load/ajax/',
        reader: {
            root: 'data'
        }
    })
});