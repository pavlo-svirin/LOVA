Ext.define('Loto.store.User', {
    extend: 'Ext.data.Store', 
    storeId: 'usersStore',
    model: 'Loto.model.User',
    autoLoad: true,
    proxy: new Ext.data.HttpProxy({
        url: '/admin/users/load/ajax/',
        reader: {
            type: 'json',
            root: 'data'
        }
    })
});