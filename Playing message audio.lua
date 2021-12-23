
--[[
    REQUIRE global_data.lua
]]

return {
	on = {
		customEvents = {
			'Adding_message_audio',         -- Event d'ajout de message
			'Playing_message_audio'         -- Event pour lancer la lecture
		},
		shellCommandResponses = { 
		    'MessageAddedToFile',           -- Reponse du shell quand les message ont été ajouté et qu'on est pres a lire
		    'MessagePlayed'                 -- Reponse du shell quand les messages on été lu par mplayer
		},
	},
    data = {
        messages = {  initial = '' },       -- Message a lire
        playing = { initial = 0 },          -- Etat de la lecture
        message_wait = { initial = 0 },     -- Nombre de message en attente de lecture
        message_dir = { initial = "/home/pi/notifications/messages/" }, -- Dossier de destination des fichiers générés
        fileName = { initial = "text" },    -- Nom des fichiers ( Autogénéré par le code)
    },
	logging = {
		level = domoticz.LOG_INFO,
		marker = 'voice',
	},
	execute = function(domoticz, item)
	    
        --[[
            On a recu l'evenement 'Adding_message_audio'
            domoticz.emitEvent('Adding_message_audio',"J'éteinds la cafetiere")
        ]]
        if (item.isCustomEvent and item.customEvent == 'Adding_message_audio') then

            domoticz.data.messages = domoticz.data.messages .. "\n" .. item.data 
            domoticz.data.message_wait = domoticz.data.message_wait + 1

            --[[
                On emet un event 'Playing_message_audio' 
                que si il n'y a aucune lecture en cours
            ]]
            if(domoticz.data.playing == 0) then
                domoticz.emitEvent('Playing_message_audio')
            end


        --[[
            On a recu l'evenement 'Adding_message_audio' , 
            il y a bien des messages en atente mais une lecture est en cours
            on relance l'evenement avec un petit delai 
        ]]
		elseif (item.isCustomEvent and item.customEvent == 'Playing_message_audio' and domoticz.data.playing == 1 and domoticz.data.message_wait > 0) then
			domoticz.emitEvent('Playing_message_audio').afterSec(5) -- delay 5 secondes
			
        --[[
            On a recu l'evenement 'Adding_message_audio' , 
            il y a bien des messages en atente et il n'y a pas de lecture en cours
            On lance la lecture
        ]]
        elseif (item.isCustomEvent and item.customEvent == 'Playing_message_audio' and domoticz.data.playing == 0 and domoticz.data.message_wait > 0) then
            
            domoticz.data.fileName = domoticz.time.makeTime().dDate -- generation de nom de fichier
            
            domoticz.data.playing = 1 -- LOCK
            
            --[[
                envoi des message dans le fichier
            ]]
			domoticz.executeShellCommand({
                command = domoticz.helpers.message2fileCmd(domoticz),
                callback = 'MessageAddedToFile',
                timeout = 20,
            })
            
            -- remise a zero
            domoticz.data.initialize('messages')
            domoticz.data.initialize('message_wait')


        --[[
            Les messages ont ete ajouté aux fichier XXXXXXX_speak.txt
            On lance la conversion en fichier XXXXXXX.wav et on le 'pipe' vers mplayer dans un shell asynchrone
        ]]
		elseif (item.isShellCommandResponse and item.shellCommandResponse == "MessageAddedToFile") then
            domoticz.executeShellCommand({
                command = domoticz.helpers.pico2waveCmd(domoticz) .. ' | ' .. domoticz.helpers.mplayerCmd(domoticz),
                callback = 'MessagePlayed',
                timeout = 20,
            })
        
        --[[
            La lecture est terminée 
            On peut detruire les fichiers inutile
        ]]
        elseif (item.isShellCommandResponse and item.shellCommandResponse == "MessagePlayed") then
            
            domoticz.executeShellCommand({
                command = domoticz.helpers.deleteAudioCmd(domoticz),
                callback = 'FileRemoved',
                timeout = 20,
            }).afterSec(20)

            domoticz.data.initialize('playing')         --UNLOCK
            domoticz.emitEvent('Playing_message_audio') --Relance une nouvelle lecture
		end
	end
}