Ext.define('Loto.model.Registrations', {
	extend: 'Ext.data.Model',
	fields: [
        "date",
        {name: "registered", type: 'int'},
        {name: "activated", type: 'int'},
        {name: "referals", type: 'int'}
    ]
});
