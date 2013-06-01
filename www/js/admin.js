Ext.Loader.setConfig({enabled:true});
Ext.application({
    name: 'Loto',
    appFolder: '/js/admin',
    controllers: [
      'Options',
      'Users'
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
                    { 
                    	title: 'Пользователи',
                    	items: [
            	            { xtype: 'users' },
            	        ]
            		}
                ]
            }]
        });
    }
});
