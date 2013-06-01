Ext.define('Loto.controller.Users', {
    extend: 'Ext.app.Controller',
    views: [ 'Users', 'UsersChart' ],
    models: [ 'User' ],
    stores: [ 'User' ]
});