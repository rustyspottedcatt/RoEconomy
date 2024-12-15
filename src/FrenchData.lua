--[[
    https://www.roblox.com/users/1539582829/profile
    https://twitter.com/zzen_a

    MIT License

    Copyright (c) 2023 rustyspotted

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
]]

export type DataEntry = {
    Key: string,
    Data: table,
}

local EconomyServer = {}

--[=[
	@prop Presets Folder
	@within AnalyticsServer
	@readonly
	References the Presets folder. 
]=]

EconomyServer.Presets = (script.Parent :: Instance).Parent

local Promise = require(EconomyServer.Presets.promise)
local Signal = require(EconomyServer.Presets.signal)



--[=[
    Creates a new virtual currency with specified parameters.
    @param currencyName string The name of the currency to create.
    @param currencySymbol CurrencySymbol The symbol representing the currency.
    @param initialDistribution number The initial distribution of the currency.
    @param inflationRate number (optional) The inflation rate of the currency. Defaults to 0 if not provided.
    @return Currency The newly created currency object.
]=]

function EconomyServer:CreateCurrency(currencyName : string, currencySymbol : CurrencySymbol, initialDistribution : number, inflationRate : number?) : Currency
	assert(currencyName, string.format("Invalid argument, got `%s` expected `%s`.", typeof(currencyName) or "nil", "string"))
	assert(currencySymbol, string.format("Invalid argument, got `%s` expected `%s`.", typeof(currencySymbol) or "nil", "CurrencySymbol :: string"))
	assert(not EconomyServer[currencyName], "Currency has already been created before.")

	local currencyMeta: Currency = {
		currencyName = currencyName,
		currencySymbol = currencySymbol,
		initialDistribution = initialDistribution or 0,
		inflationRate = (((inflationRate or 0) > 0 or (inflationRate or 0) < 1 and (inflationRate or 0)) or 0),
		currencyHolders = {},
		CurrencyEarned = Signal.new(),
		CurrencySpent = Signal.new(),
		CurrencyBalanceChanged = Signal.new(),
	}
	EconomyServer[currencyMeta] = currencyMeta

	return EconomyServer[currencyMeta]
end

return EconomyServer