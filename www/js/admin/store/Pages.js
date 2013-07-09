Ext.define('Loto.store.Pages', {
    extend: 'Ext.data.Store', 
    fields: ['code', 'caption'],
    data : [
        {"code":"MAIN", "caption":"Главная страница"},
        {"code":"CABINET", "caption":"Кабинет"},
        {"code":"PROFILE", "caption":"Профиль"}
    ]
});