CaveBot.Extensions.Withdraw = {}

CaveBot.Extensions.Withdraw.setup = function()
	CaveBot.registerAction("withdraw", "#002FFF", function(value, retries)
		-- validation
		local data = string.split(value, ",")
		if #data ~= 3 then
			print("CaveBot[Withdraw]: incorrect data! skipping")
			return false
		end

		-- variables declaration
		local source = tonumber(data[1])
		local id = tonumber(data[2])
		local amount = tonumber(data[3])

		-- validation for correct values
		if not id or not amount then
			print("CaveBot[Withdraw]: incorrect id or amount! skipping") 
			return false
		end

		-- check for retries
		if retries > 100 then
			print("CaveBot[Withdraw]: actions limit reached, proceeding")
			return true
		end

		-- check for items
		if itemAmount(id) >= amount then
			print("CaveBot[Withdraw]: enough items, proceeding")
			return true
		end

		CaveBot.WithdrawItem(id, amount, source)
		CaveBot.PingDelay()
		return "retry"
  	end)

 CaveBot.Editor.registerAction("withdraw", "withdraw", {
  value="source,id,amount",
  title="Withdraw Items",
  description="index/inbox, item id and amount",
 })
end