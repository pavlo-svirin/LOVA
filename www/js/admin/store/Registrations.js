Ext.define('Loto.store.Registrations', {
    extend: 'Ext.data.Store', 
    storeId: 'regStore',
    model: 'Loto.model.Registrations',
    autoLoad: true,
    proxy: new Ext.data.HttpProxy({
        url: '/admin/users/chart/ajax/',
        reader: {
            type: 'json',
            root: 'data'
        }
    })
});