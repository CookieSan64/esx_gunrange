local scores = {}
local canStart = true
local maxDistance = 10.0 -- Distance maximale à laquelle les joueurs peuvent voir le tableau des scores

ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function getIdentity(source, callback)
    local xPlayer = ESX.GetPlayerFromId(source)

    MySQL.Async.fetchAll(
        'SELECT identifier, firstname, lastname, dateofbirth, sex, height FROM `users` WHERE `identifier` = @identifier',
        {['@identifier'] = xPlayer.identifier},
        function(result)
            if result[1].firstname ~= nil then
                local data = {
                    identifier = result[1].identifier,
                    firstname = result[1].firstname,
                    lastname = result[1].lastname,
                    dateofbirth = result[1].dateofbirth,
                    sex = result[1].sex,
                    height = result[1].height
                }
                callback(data)
            else
                local data = {
                    identifier = '',
                    firstname = '',
                    lastname = '',
                    dateofbirth = '',
                    sex = '',
                    height = ''
                }
                callback(data)
            end
        end)
end

ESX.RegisterServerCallback('esx_gunrange:canshoot', function(source, cb)
    if canStart then
        cb(true)
    else
        cb(false)
    end
end)

RegisterNetEvent('esx_gunrange:startShooting')
AddEventHandler('esx_gunrange:startShooting', function(wTime, targets)
    canStart = false
    SetTimeout((wTime * targets), function() canStart = true end)
end)

RegisterNetEvent('esx_gunrange:showresulttoNearbyPlayers')
AddEventHandler('esx_gunrange:showresulttoNearbyPlayers', function(difficulty_name, points, targets)
    getIdentity(source, function(data)
        if difficulty == 1 then
            difficulty_name = "Facile"
        elseif difficulty == 2 then
            difficulty_name = "Normal"
        elseif difficulty == 3 then
            difficulty_name = "Difficile"
        elseif difficulty == 4 then
            difficulty_name = "Très difficile"
        elseif difficulty == 5 then
            difficulty_name = "Impossible"
        end
      TriggerClientEvent('esx_gunrange:sendresultsforplayers', -1,
                         data.firstname, data.lastname, difficulty_name, points,
                         targets)
      insertScore(data.identifier, data.firstname, data.lastname, difficulty_name, points, targets)
    end)
end)
  

function insertScore(playerIdentifier, firstname, lastname, difficulty_name, score, targets)
    MySQL.Async.execute('INSERT INTO gunrange_scores (identifier, firstname, lastname, difficulty_name, score, targets) VALUES (@identifier, @firstname, @lastname, @difficulty_name, @score, @targets)', {
        ['@identifier'] = playerIdentifier,
        ['@firstname'] = firstname,
        ['@lastname'] = lastname,
        ['@difficulty_name'] = difficulty_name,
        ['@score'] = score,
        ['@targets'] = targets
    }, function(rowsChanged)
        if rowsChanged > 0 then
            print('Score inserted for player ' .. playerIdentifier)
        else
            print('Failed to insert score for player ' .. playerIdentifier)
        end
    end)
end   

RegisterNetEvent('esx_gunrange:updateScoreboard')
AddEventHandler('esx_gunrange:updateScoreboard', function(difficulty_name, points, targets)
    getIdentity(source, function(data)
        local playerIdentifier = data.identifier
        insertScore(playerIdentifier, data.firstname, data.lastname, difficulty_name, points, targets)
        TriggerClientEvent('esx_gunrange:updateScoreboard', -1, scores)
    end)
end)

ESX.RegisterServerCallback('esx_gunrange:GetScores', function(source, cb)
    MySQL.Async.fetchAll('SELECT * FROM gunrange_scores ORDER BY score DESC', {}, function(rows)
        local scores = {}
        for i = 1, #rows, 1 do
          table.insert(scores, {
            identifier = rows[i].identifier,
            firstname = rows[i].firstname,
            lastname = rows[i].lastname,
            difficulty_name = rows[i].difficulty_name,
            score = rows[i].score,
            targets = rows[i].targets
          })
        end
        cb(scores)
      end)
    end)