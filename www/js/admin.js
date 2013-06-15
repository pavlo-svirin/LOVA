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
            layout: 'fit',
           
            items: [{
                xtype: 'tabpanel',
                renderTo: 'admin-screen',
                width: "100%",
                activeTab: 0,
                frame: true,
                defaults: {
                    autoHeight: true
                },
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
