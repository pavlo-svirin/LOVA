Ext.define('Loto.store.UserDetails', {
    extend: 'Ext.data.Store', 
    model: 'Loto.model.UserDetails',
    autoLoad: false,
    proxy: new Ext.data.HttpProxy({
        type: 'jsonp',
    	url: '/admin/users/load/ajax/',
        simpleSortMode: true,
        reader: {
            root: 'data'
        }
    })
});