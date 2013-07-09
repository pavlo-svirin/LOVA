Ext.define('Loto.store.Languages', {
    extend: 'Ext.data.Store', 
    fields: ['code', 'caption'],
    data : [
        { "code": "ru", "caption": "Russian" },
        { "code": "ua", "caption": "Ukrainian" },
        { "code": "en", "caption": "English" }
    ]
});