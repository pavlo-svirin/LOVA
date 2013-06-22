Ext.Loader.setConfig({enabled:true});
Ext.application({
    name: 'Loto',
    appFolder: '/js/admin',
    controllers: [
      'Options',
      'Users',
      'Emails'
    ],
    launch: function()
    {
        Ext.create('Ext.container.Viewport', {
            layout: 'card',
            items: [{
                xtype: 'tabpanel',
                renderTo: 'admin-screen',
                activeTab: 0,
                frame: true,
                items: [
                    { xtype: 'options' },
    	            { xtype: 'users' },
    	            { xtype: 'usersChart' },
    	            { xtype: 'emails' }
                ]
            }]
        });
    }
});
