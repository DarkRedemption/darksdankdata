local rankTable = {}
rankTable.__index = rankTable

function rankTable:getOverallEnemyKdRank()
  local query = [[SELECT 
    SUM(stats.traitor_innocent_kills + stats.traitor_detective_kills + stats.innocent_traitor_kills + stats.detective_traitor_kills) * 1.000 / 
    SUM(stats.traitor_innocent_deaths + stats.traitor_detective_deaths + stats.traitor_traitor_deaths + stats.traitor_world_deaths +
    stats.detective_innocent_deaths + stats.detective_traitor_deaths + stats.detective_detective_deaths + stats.detective_world_deaths +
    stats.innocent_traitor_deaths + stats.innocent_detective_deaths + stats.innocent_innocent_deaths + stats.innocent_world_deaths) as overall_enemy_kd, 
    player_id.last_known_name
    FROM ]] .. self.tables.AggregateStats.tableName .. [[ as stats
    LEFT JOIN ]] .. self.tables.PlayerId.tableName .. [[ as player_id on stats.player_id == player_id.id
    WHERE stats.traitor_rounds > 100
    GROUP BY stats.player_id
    ORDER BY overall_enemy_kd DESC
    LIMIT 25
    ]]
  return DDD.SqlTable:query("RankTable:getOverallEnemyKdRank", query)
end

function rankTable:getTotalEnemyKillRank()
  local query = [[SELECT 
                SUM(stats.traitor_innocent_kills + 
                stats.traitor_detective_kills + 
                stats.innocent_traitor_kills + 
                stats.detective_traitor_kills) as total_enemy_kills, player_id.last_known_name
                FROM ]] .. self.tables.AggregateStats.tableName .. [[ as stats
                LEFT JOIN ]] .. self.tables.PlayerId.tableName .. [[ as player_id on stats.player_id == player_id.id
                WHERE (stats.traitor_rounds + stats.innocent_rounds + stats.detective_rounds) > 250
                GROUP BY stats.player_id
                ORDER BY  stats.traitor_innocent_kills DESC
                LIMIT 25
                ]]
  return DDD.SqlTable:query("RankTable:getTotalEnemyKillRank", query)
end

function rankTable:getTotalRoundsPlayedRank()
  local query = [[SELECT 
                  SUM(stats.traitor_rounds + stats.innocent_rounds + stats.detective_rounds) as total_rounds_played,
                  player_id.last_known_name
                  FROM ]] .. self.tables.AggregateStats.tableName .. [[ as stats
                  LEFT JOIN ]] .. self.tables.PlayerId.tableName .. [[ as player_id on stats.player_id == player_id.id
                  GROUP BY stats.player_id
                  ORDER BY total_rounds_played DESC
                  LIMIT 25
                ]]
  return DDD.SqlTable:query("RankTable:getTotalRoundsPlayedRank", query)
end

function rankTable:update()
  self.rankings["overall_enemy_kd"] = self:getOverallEnemyKdRank()
  self.rankings["total_enemy_kills"] = self:getTotalEnemyKillRank()
  self.rankings["total_rounds_played"] = self:getTotalRoundsPlayedRank()
end

function rankTable:new(tables)
  local newTable = {}
  setmetatable(newTable, self)
  newTable.rankings = {}
  newTable.tables = tables or DDD.Database.Tables
  return newTable
end

DDD.Rank.RankTable = rankTable:new()

util.AddNetworkString("DDDGetRankings")

net.Receive("DDDGetRankings", function(len, ply)
    DDD.Rank.RankTable:update()
    net.Start("DDDGetRankings")
    net.WriteTable(DDD.Rank.RankTable.rankings)
    net.Send(ply)
end)