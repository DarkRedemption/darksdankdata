local rankTable = {}
rankTable.__index = rankTable

function rankTable:getOverallEnemyKdRank()
  local query = [[SELECT
    ROUND(
    SUM(stats.traitor_innocent_kills + stats.traitor_detective_kills + stats.innocent_traitor_kills + stats.detective_traitor_kills) * 1.000 / 
    SUM(stats.traitor_innocent_deaths + stats.traitor_detective_deaths + stats.traitor_traitor_deaths + stats.traitor_world_deaths +
    stats.detective_innocent_deaths + stats.detective_traitor_deaths + stats.detective_detective_deaths + stats.detective_world_deaths +
    stats.innocent_traitor_deaths + stats.innocent_detective_deaths + stats.innocent_innocent_deaths + stats.innocent_world_deaths), 
    3) as overall_enemy_kd, 
    player_id.last_known_name
    FROM ]] .. self.tables.AggregateStats.tableName .. [[ as stats
    LEFT JOIN ]] .. self.tables.PlayerId.tableName .. [[ as player_id on stats.player_id == player_id.id
    WHERE (stats.traitor_rounds + stats.innocent_rounds + stats.detective_rounds) > 500
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
                GROUP BY stats.player_id
                ORDER BY stats.traitor_innocent_kills DESC
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

function rankTable:getTraitorEnemyKdRank()
  local query = [[SELECT
                  ROUND(
                  SUM(stats.traitor_innocent_kills + stats.traitor_detective_kills) * 1.000 / 
                  SUM(stats.traitor_innocent_deaths + stats.traitor_detective_deaths + stats.traitor_traitor_deaths + stats.traitor_world_deaths),
                  3) as traitor_enemy_kd, 
                  player_id.last_known_name
                  FROM ddd_aggregate_stats as stats
                  LEFT JOIN ddd_player_id as player_id on stats.player_id == player_id.id
                  WHERE stats.traitor_rounds > 125
                  GROUP BY stats.player_id
                  ORDER BY traitor_enemy_kd DESC
                  LIMIT 25
  ]]
  return DDD.SqlTable:query("RankTable:getTraitorEnemyKdRank", query)
end

function rankTable:getTraitorEnemyKillRank()
  local query = [[SELECT SUM(stats.traitor_innocent_kills + stats.traitor_detective_kills) as traitor_enemy_kills, player_id.last_known_name
                  from ddd_aggregate_stats as stats
                  LEFT JOIN ddd_player_id as player_id on stats.player_id == player_id.id
                  GROUP BY stats.player_id
                  ORDER BY stats.traitor_innocent_kills DESC
                  LIMIT 25
                ]]
  return DDD.SqlTable:query("RankTable:getTraitorEnemyKillRank", query)
end

function rankTable:getTraitorInnocentKillRank()
  local query = [[SELECT stats.traitor_innocent_kills, player_id.last_known_name
                  from ddd_aggregate_stats as stats
                  LEFT JOIN ddd_player_id as player_id on stats.player_id == player_id.id
                  GROUP BY stats.player_id
                  ORDER BY stats.traitor_innocent_kills DESC
                  LIMIT 25
                ]]
  return DDD.SqlTable:query("RankTable:getTraitorInnocentKillRank", query)
end

function rankTable:getTraitorDetectiveKillRank()
  local query = [[SELECT stats.traitor_detective_kills, player_id.last_known_name
                  from ddd_aggregate_stats as stats
                  LEFT JOIN ddd_player_id as player_id on stats.player_id == player_id.id
                  GROUP BY stats.player_id
                  ORDER BY stats.traitor_innocent_kills DESC
                  LIMIT 25
                ]]
  return DDD.SqlTable:query("RankTable:getTraitorInnocentKillRank", query)
end

function rankTable:getTraitorRoundsPlayedRank()
    local query = [[SELECT 
                  stats.traitor_rounds as traitor_rounds_played,
                  player_id.last_known_name
                  FROM ]] .. self.tables.AggregateStats.tableName .. [[ as stats
                  LEFT JOIN ]] .. self.tables.PlayerId.tableName .. [[ as player_id on stats.player_id == player_id.id
                  GROUP BY stats.player_id
                  ORDER BY traitor_rounds_played DESC
                  LIMIT 25
                ]]
    return DDD.SqlTable:query("RankTable:getTraitorRoundsPlayedRank", query)
end

function rankTable:getInnocentTraitorKdRank()
  local query = [[SELECT
                  ROUND(
                  stats.innocent_traitor_kills * 1.000 / 
                  SUM(stats.innocent_traitor_deaths + stats.innocent_detective_deaths + stats.innocent_innocent_deaths + stats.innocent_world_deaths),
                  3) as innocent_traitor_kd, 
                  player_id.last_known_name
                  FROM ddd_aggregate_stats as stats
                  LEFT JOIN ddd_player_id as player_id on stats.player_id == player_id.id
                  WHERE stats.innocent_rounds > 250
                  GROUP BY stats.player_id
                  ORDER BY innocent_traitor_kd DESC
                  LIMIT 25
  ]]
  return DDD.SqlTable:query("RankTable:getInnocentTraitorKdRank", query)
end

function rankTable:getInnocentTraitorKillRank()
  local query = [[SELECT stats.innocent_traitor_kills, player_id.last_known_name
                  from ddd_aggregate_stats as stats
                  LEFT JOIN ddd_player_id as player_id on stats.player_id == player_id.id
                  GROUP BY stats.player_id
                  ORDER BY stats.innocent_traitor_kills DESC
                  LIMIT 25
                ]]
  return DDD.SqlTable:query("RankTable:getInnocentTraitorKillRank", query)
end

function rankTable:getInnocentRoundsPlayedRank()
    local query = [[SELECT 
                  stats.innocent_rounds as innocent_rounds_played,
                  player_id.last_known_name
                  FROM ]] .. self.tables.AggregateStats.tableName .. [[ as stats
                  LEFT JOIN ]] .. self.tables.PlayerId.tableName .. [[ as player_id on stats.player_id == player_id.id
                  GROUP BY stats.player_id
                  ORDER BY innocent_rounds_played DESC
                  LIMIT 25
                ]]
    return DDD.SqlTable:query("RankTable:getInnocentRoundsPlayedRank", query)
end

function rankTable:getDetectiveTraitorKdRank()
  local query = [[SELECT
                  ROUND(
                  stats.detective_traitor_kills * 1.000 / 
                  SUM(stats.detective_traitor_deaths + stats.detective_innocent_deaths + stats.detective_detective_deaths + stats.detective_world_deaths),
                  3) as detective_traitor_kd, 
                  player_id.last_known_name
                  FROM ddd_aggregate_stats as stats
                  LEFT JOIN ddd_player_id as player_id on stats.player_id == player_id.id
                  WHERE stats.detective_rounds > 75
                  GROUP BY stats.player_id
                  ORDER BY detective_traitor_kd DESC
                  LIMIT 25
  ]]
  return DDD.SqlTable:query("RankTable:getDetectiveTraitorKdRank", query)
end

function rankTable:getDetectiveTraitorKillRank()
  local query = [[SELECT stats.detective_traitor_kills, player_id.last_known_name
                  from ddd_aggregate_stats as stats
                  LEFT JOIN ddd_player_id as player_id on stats.player_id == player_id.id
                  GROUP BY stats.player_id
                  ORDER BY stats.detective_traitor_kills DESC
                  LIMIT 25
                ]]
  return DDD.SqlTable:query("RankTable:getDetectiveTraitorKillRank", query)
end

function rankTable:getDetectiveRoundsPlayedRank()
    local query = [[SELECT 
                  stats.detective_rounds as detective_rounds_played,
                  player_id.last_known_name
                  FROM ]] .. self.tables.AggregateStats.tableName .. [[ as stats
                  LEFT JOIN ]] .. self.tables.PlayerId.tableName .. [[ as player_id on stats.player_id == player_id.id
                  GROUP BY stats.player_id
                  ORDER BY detective_rounds_played DESC
                  LIMIT 25
                ]]
    return DDD.SqlTable:query("RankTable:getDetectiveRoundsPlayedRank", query)
end

function rankTable:update()
  self.rankings["overall_enemy_kd"] = self:getOverallEnemyKdRank()
  self.rankings["total_enemy_kills"] = self:getTotalEnemyKillRank()
  self.rankings["total_rounds_played"] = self:getTotalRoundsPlayedRank()
  
  self.rankings["detective_traitor_kd"] = self:getDetectiveTraitorKdRank()
  self.rankings["detective_traitor_kills"] = self:getDetectiveTraitorKillRank()
  self.rankings["detective_rounds_played"] = self:getDetectiveRoundsPlayedRank()
  
  self.rankings["traitor_enemy_kd"] = self:getTraitorEnemyKdRank()
  self.rankings["traitor_enemy_kills"] = self:getTraitorEnemyKillRank()
  self.rankings["traitor_innocent_kills"] = self:getTraitorInnocentKillRank()
  self.rankings["traitor_detective_kills"] = self:getTraitorDetectiveKillRank()
  self.rankings["traitor_rounds_played"] = self:getTraitorRoundsPlayedRank()
  
  self.rankings["innocent_traitor_kd"] = self:getInnocentTraitorKdRank()
  self.rankings["innocent_traitor_kills"] = self:getInnocentTraitorKillRank()
  self.rankings["innocent_rounds_played"] = self:getInnocentRoundsPlayedRank()
end

function rankTable:new(tables)
  local newTable = {}
  setmetatable(newTable, self)
  newTable.rankings = {}
  newTable.tables = tables or DDD.Database.Tables
  newTable:update()
  return newTable
end

DDD.Rank.RankTable = rankTable:new()

util.AddNetworkString("DDDGetRankings")

net.Receive("DDDGetRankings", function(len, ply)
    net.Start("DDDGetRankings")
    net.WriteTable(DDD.Rank.RankTable.rankings)
    net.Send(ply)
end)