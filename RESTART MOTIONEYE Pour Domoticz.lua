--[[
RESTART MOTIONEYE Pour Domoticz

Function:
    -redemarrage de plusieur ESP32-CAM sous TASMOTA-WEBCAM
    -Redemarrage de Motioneye
    -Desactivation de la detection de mouvement
]]--


return {
	on = {
		system = {
			'start',
		},
		shellCommandResponses = { 'MotioneyeRestarted' },
		httpResponses = { 'DisabledDetection' },
	},
	logging = {
		level = domoticz.LOG_INFO,
		marker = 'Restart Motioneye',
	},
	
	data = {
            cam = { initial = { 60, 61, 62 } }  --Dernier chiffre des ip de vos ESP32-CAM
    },
	execute = function(domoticz, item)
		
		-- Si 'item' est un evenement systeme
		if item.isSystemEvent then
		    
		    domoticz.log('Domoticz has started', domoticz.LOG_INFO)
		    
    		--redemarrage des ESP32-CAM sous TASMOTA-WEBCAM
    		for i, cam in pairs(domoticz.data.cam) do
    		    --domoticz.log('Restarting Cam : '..cam)
                os.execute('curl -s "http://192.168.1.'..cam..'/cm?cmnd=WcInit"')
                os.execute('curl -s "http://192.168.1.'..cam..'/cm?cmnd=WcStream%201"')
            end
    		
    		
    		--Redemarrage de Motioneye
    		domoticz.executeShellCommand({
                command = 'sudo systemctl restart motioneye',
                callback = 'MotioneyeRestarted',
                timeout = 20,
            })
        
        --[[ 
            Si 'item' est une reponse de commande shell,
            On va demander d'ouvrir l'url de desactivation de la detection,
            Mais attention , motioneye a besoin d'un certain temps pour demarrer,
            il faut lui laisser le temps... 
            Donc , ne pas oublier de rajouter le 'afterSec(10)' pour que domoticz ne lance l'url que 10 secondes apres la reponse shell
        ]]--
    	elseif (item.isShellCommandResponse) then
    	    
            if (item.statusCode==0) then
                
                domoticz.log('Disabling detection')
                
                domoticz.openURL({
                    url = 'http://192.168.1.2:7999/0/detection/pause',
                    method = 'GET',
                    callback = 'DisabledDetection'
                }).afterSec(10)
            end
    
        elseif (item.isHTTPResponse) then
            if (item.ok) then
                domoticz.log('Disabled detection')
            end
            
        end

	end
}