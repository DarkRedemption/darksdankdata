util.AddNetworkString("DDDGetStats")

net.Receive("DDDGetStats", function(len, ply)
    local playerStats = DDD.Database.PlayerStats:new(ply)
    playerStats:updateStats()
    net.Start("DDDGetStats")
    net.WriteTable(playerStats.statsTable)
    net.Send(ply)
end)