return {
	query = function(n,f,...)                           -- query function(sql, function, format)
		if (rp && rp._Stats) then
			rp._Stats:Query(string.format(n, ...),f)
			return
		end
		if (MySQLite) then
			MySQLite.query(string.format(n, ...),f)
			return
		end
		sql.Query(string.format(n, ...),f)
	end
}