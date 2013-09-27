Ext.define('Loto.controller.Options', {
    extend: 'Ext.app.Controller',
    views: [
        'Options'
    ],

    init: function() {
        this.control({
            'options': {
                render: this._load
            },
            'options button[action=save]': {
                click: this._save
            },
            'options checkbox[name=randomNumbers]': {
                change: this._toggleRandomGame
            },
            'options sliderfield': {
                change: this._ballanceSliders
            }
        });
    },
    
    _load: function(options)
    {
        options.getForm().load({
            url: '/admin/options/load/ajax/'
        });
    },
    
    _save: function(btn)
    {
    	var form = btn.up('form').getForm();
	    form.standardSubmit = true;
        if(form.isValid())
        {
        	form.submit({
        		url: '/admin/options/save/'
        	});
        }
    },


    _toggleRandomGame: function(chkbox, checked)
    {
    	var luckyNumbers = chkbox.up("fieldset").down("textfield[name='luckyNumbers']");
    	var lovaNumber = chkbox.up("fieldset").down("textfield[name='lovaNumber']");
        if(checked)
        {
        	luckyNumbers.disable();
        	lovaNumber.disable();
        }
        else
        {
        	luckyNumbers.enable();
        	lovaNumber.enable();
        }
    },
    
    _ballanceSliders: function(slider)
    {
        var sliders = slider.up("fieldset").query("sliderfield");
        sliders = Ext.Array.remove(sliders, slider);
        var currentSlider = slider.thumbs[0].value;
        var otherSliders = this._sumSliders(sliders);
        if((otherSliders + currentSlider) > 100)
        {
        	slider.setValue(100 - otherSliders)
        	slider.syncThumbs();
        }
        var labels = slider.up("fieldset").query("label[name='" + slider.name + "']");
        if(labels && labels.length > 0)
        {
        	labels[0].update(String(slider.thumbs[0].value) + '%');
        }
    },
      
    _sumSliders: function(sliders)
    {
        var total = 0;
        for(var i = 0; i < sliders.length; i++)
        {
        	if(!isNaN(sliders[i].thumbs[0].value))
        	{
        		total += sliders[i].thumbs[0].value;
        	}
        }
        return total;
    }    
});    
 