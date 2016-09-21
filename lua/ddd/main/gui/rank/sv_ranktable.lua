local rankTable = {}
rankTable.__index = rankTable

--[[
Queries the database for the rank information and creates default information if it can't find any.
PARAM functionName:String - The name of the function that called rankQuery, for logging purposes.
PARAM query:String - The SQL query.
RETURNS A table with the rankings or a table containing a message that there are no ranks yet for this category.
]]
local function rankQuery(functionName, query, valueName)
  local result = DDD.SqlTable:query("RankTable:getOverallEnemyKdRank", query)
  
  if (result == 0) then --SQL found no results but didn't error
    local defaultRank = {}
    local defaultTable = {}
    defaultRank["last_known_name"] = "No one has met the prerequisites to be ranked for this category."
    defaultRank["value"] = 0
    table.insert(defaultTable, defaultRank)
    return defaultTable
  else
    return result
  end
end

function rankTable:getOverallEnemyKdRank()
  local query = [[SELECT
    ROUND(
    SUM(stats.traitor_innocent_kills + stats.traitor_detective_kills + stats.innocent_traitor_kills + stats.detective_traitor_kills) * 1.000 / 
    SUM(stats.traitor_innocent_deaths + stats.traitor_detective_deaths + stats.traitor_traitor_deaths + stats.traitor_world_deaths +
    stats.detective_innocent_deaths + stats.detective_traitor_deaths + stats.detective_detective_deaths + stats.detective_world_deaths +
    stats.innocent_traitor_deaths + stats.innocent_detective_deaths + stats.innocent_innocent_deaths + stats.innocent_world_deaths), 
    3) as value, 
    player_id.last_known_name
    FROM ]] .. self.tables.AggregateStats.tableName .. [[ as stats
    LEFT JOIN ]] .. self.tables.PlayerId.tableName .. [[ as player_id on stats.player_id == player_id.id
    WHERE (stats.traitor_rounds + stats.innocent_rounds + stats.detective_rounds) > 500
    GROUP BY stats.player_id
    ORDER BY value DESC
    LIMIT 25
    ]]
  return rankQuery("RankTable:getOverallEnemyKdRank", query)
end

function rankTable:getTotalEnemyKillRank()
  local query = [[SELECT 
                SUM(stats.traitor_innocent_kills + 
                stats.traitor_detective_kills + 
                stats.innocent_traitor_kills + 
                stats.detective_traitor_kills) as value, player_id.last_known_name
                FROM ]] .. self.tables.AggregateStats.tableName .. [[ as stats
                LEFT JOIN ]] .. self.tables.PlayerId.tableName .. [[ as player_id on stats.player_id == player_id.id
                GROUP BY stats.player_id
                ORDER BY value DESC
                LIMIT 25
                ]]
  return rankQuery("RankTable:getTotalEnemyKillRank", query)
end

function rankTable:getTotalRoundsPlayedRank()
  local query = [[SELECT
                  SUM(stats.traitor_rounds + stats.innocent_rounds + stats.detective_rounds) as value,
                  player_id.last_known_name
                  FROM ]] .. self.tables.AggregateStats.tableName .. [[ as stats
                  LEFT JOIN ]] .. self.tables.PlayerId.tableName .. [[ as player_id on stats.player_id == player_id.id
                  GROUP BY stats.player_id
                  ORDER BY value DESC
                  LIMIT 25
                ]]
  return rankQuery("RankTable:getTotalRoundsPlayedRank", query)
end

function rankTable:getTraitorEnemyKdRank()
  local query = [[SELECT
                  ROUND(
                  SUM(stats.traitor_innocent_kills + stats.traitor_detective_kills) * 1.000 / 
                  SUM(stats.traitor_innocent_deaths + stats.traitor_detective_deaths + stats.traitor_traitor_deaths + stats.traitor_world_deaths),
                  3) as value, 
                  player_id.last_known_name
                  FROM ddd_aggregate_stats as stats
                  LEFT JOIN ddd_player_id as player_id on stats.player_id == player_id.id
                  WHERE stats.traitor_rounds > 125
                  GROUP BY stats.player_id
                  ORDER BY value DESC
                  LIMIT 25
  ]]
  return rankQuery("RankTable:getTraitorEnemyKdRank", query)
end

function rankTable:getTraitorEnemyKillRank()
  local query = [[SELECT SUM(stats.traitor_innocent_kills + stats.traitor_detective_kills) as value, player_id.last_known_name
                  from ddd_aggregate_stats as stats
                  LEFT JOIN ddd_player_id as player_id on stats.player_id == player_id.id
                  GROUP BY stats.player_id
                  ORDER BY value DESC
                  LIMIT 25
                ]]
  return rankQuery("RankTable:getTraitorEnemyKillRank", query)
end

function rankTable:getTraitorInnocentKillRank()
  local query = [[SELECT stats.traitor_innocent_kills as value, player_id.last_known_name
                  from ddd_aggregate_stats as stats
                  LEFT JOIN ddd_player_id as player_id on stats.player_id == player_id.id
                  GROUP BY stats.player_id
                  ORDER BY value DESC
                  LIMIT 25
                ]]
  return rankQuery("RankTable:getTraitorInnocentKillRank", query)
end

function rankTable:getTraitorDetectiveKillRank()
  local query = [[SELECT stats.traitor_detective_kills, player_id.last_known_name
                  from ddd_aggregate_stats as stats
                  LEFT JOIN ddd_player_id as player_id on stats.player_id == player_id.id
                  GROUP BY stats.player_id
                  ORDER BY stats.traitor_innocent_kills DESC
                  LIMIT 25
                ]]
  return rankQuery("RankTable:getTraitorInnocentKillRank", query)
end

function rankTable:getTraitorRoundsPlayedRank()
    local query = [[SELECT 
                  stats.traitor_rounds as value,
                  player_id.last_known_name
                  FROM ]] .. self.tables.AggregateStats.tableName .. [[ as stats
                  LEFT JOIN ]] .. self.tables.PlayerId.tableName .. [[ as player_id on stats.player_id == player_id.id
                  GROUP BY stats.player_id
                  ORDER BY value DESC
                  LIMIT 25
                ]]
    return rankQuery("RankTable:getTraitorRoundsPlayedRank", query)
end

function rankTable:getInnocentTraitorKdRank()
  local query = [[SELECT
                  ROUND(
                  stats.innocent_traitor_kills * 1.000 / 
                  SUM(stats.innocent_traitor_deaths + stats.innocent_detective_deaths + stats.innocent_innocent_deaths + stats.innocent_world_deaths),
                  3) as value, 
                  player_id.last_known_name
                  FROM ddd_aggregate_stats as stats
                  LEFT JOIN ddd_player_id as player_id on stats.player_id == player_id.id
                  WHERE stats.innocent_rounds > 250
                  GROUP BY stats.player_id
                  ORDER BY value DESC
                  LIMIT 25
  ]]
  return rankQuery("RankTable:getInnocentTraitorKdRank", query)
end

function rankTable:getInnocentTraitorKillRank()
  local query = [[SELECT stats.innocent_traitor_kills as value, player_id.last_known_name
                  from ddd_aggregate_stats as stats
                  LEFT JOIN ddd_player_id as player_id on stats.player_id == player_id.id
                  GROUP BY stats.player_id
                  ORDER BY value DESC
                  LIMIT 25
                ]]
  return rankQuery("RankTable:getInnocentTraitorKillRank", query)
end

function rankTable:getInnocentRoundsPlayedRank()
    local query = [[SELECT 
                  stats.innocent_rounds as value,
                  player_id.last_known_name
                  FROM ]] .. self.tables.AggregateStats.tableName .. [[ as stats
                  LEFT JOIN ]] .. self.tables.PlayerId.tableName .. [[ as player_id on stats.player_id == player_id.id
                  GROUP BY stats.player_id
                  ORDER BY value DESC
                  LIMIT 25
                ]]
    return rankQuery("RankTable:getInnocentRoundsPlayedRank", query)
end

function rankTable:getDetectiveTraitorKdRank()
  local query = [[SELECT
                  ROUND(
                  stats.detective_traitor_kills * 1.000 / 
                  SUM(stats.detective_traitor_deaths + stats.detective_innocent_deaths + stats.detective_detective_deaths + stats.detective_world_deaths),
                  3) as value, 
                  player_id.last_known_name
                  FROM ddd_aggregate_stats as stats
                  LEFT JOIN ddd_player_id as player_id on stats.player_id == player_id.id
                  WHERE stats.detective_rounds > 75
                  GROUP BY stats.player_id
                  ORDER BY value DESC
                  LIMIT 25
  ]]
  return rankQuery("RankTable:getDetectiveTraitorKdRank", query)
end

function rankTable:getDetectiveTraitorKillRank()
  local query = [[SELECT stats.detective_traitor_kills as value, player_id.last_known_name
                  from ddd_aggregate_stats as stats
                  LEFT JOIN ddd_player_id as player_id on stats.player_id == player_id.id
                  GROUP BY stats.player_id
                  ORDER BY value DESC
                  LIMIT 25
                ]]
  return rankQuery("RankTable:getDetectiveTraitorKillRank", query)
end

function rankTable:getDetectiveRoundsPlayedRank()
    local query = [[SELECT 
                  stats.detective_rounds as value,
                  player_id.last_known_name
                  FROM ]] .. self.tables.AggregateStats.tableName .. [[ as stats
                  LEFT JOIN ]] .. self.tables.PlayerId.tableName .. [[ as player_id on stats.player_id == player_id.id
                  GROUP BY stats.player_id
                  ORDER BY value DESC
                  LIMIT 25
                ]]
    return rankQuery("RankTable:getDetectiveRoundsPlayedRank", query)
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