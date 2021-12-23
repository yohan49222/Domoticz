
--[[
    Attention le nom de ce fichier DOIT etre 'global_data.lua'
]]
return {
	helpers = {

        --[[
            Construction de la commande servant a transformer une fichier '.txt' 
            en fichier '.wav'
        ]]
        pico2waveCmd = function(domoticz) 
            local dir = domoticz.data.message_dir
            local file = domoticz.data.fileName
            
            return 'sudo pico2wave  -l  fr-FR -w "'..dir..file..'.wav" < "'..dir..file..'_speak.txt"'
        end,

        --[[
            Construction de la commande de lancement de mplayer
        ]]
        mplayerCmd = function(domoticz) 
            local dir = domoticz.data.message_dir
            local file = domoticz.data.fileName
            
            return 'sudo mplayer "'..dir..file..'.wav"' --&>/dev/null
        end,

        --[[
            Remplissage du fichier 
        ]]
        message2fileCmd = function(domoticz) 
            local dir = domoticz.data.message_dir
            local file = domoticz.data.fileName
            local msgs = domoticz.data.messages
            
            return 'echo "'..msgs..'" > "'..dir..file..'_speak.txt"'
        end,


        --[[
            Destruction de fichiers inutilisés
        ]]
        deleteAudioCmd = function(domoticz) 
            local dir = domoticz.data.message_dir
            local file = domoticz.data.fileName
            
            return 'sudo rm -f "'..dir..file..'_speak.txt" "'..dir..file..'.wav"'
        end,
    },
}