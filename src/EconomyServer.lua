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

export type CurrencySymbol = string
export type Currency = {
	currencyName: string,
	currencySymbol: CurrencySymbol,
	initialDistribution: number,
	inflationRate: number?,
	currencyHolders : table,
	CurrencyEarned: RBXScriptConnection,
	CurrencySpent: RBXScriptConnection,
	CurrencyBalanceChanged: RBXScriptConnection,
}

--[=[
	@class EconomyServer
	@server

	```lua
	local Economy = require(somewhere.RoEconomy)

	-- Create a currency:
    local USD = Economy:CreateCurrency("USD" :: string, "$" :: string?, 0 :: number, 0.2 :: number)
    
	-- do stuff
    
	```
]=]

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

--[=[
    Retrieves a currency object by its name.
    @param currencyName string The name of the currency to retrieve.
    @return Currency|nil The currency object, or nil if not found.
]=]

function EconomyServer:GetCurrency(currencyName : string) : Currency | nil
    for _, currency in pairs(self) do
        if currency.currencyName == currencyName then
            return currency
        end
    end

    return nil
end

--[=[
    Converts an amount of currency from one type to another based on specified exchange rates.
    @param amount number The amount of currency to convert.
    @param fromCurrency Currency The currency to convert from.
    @param toCurrency Currency The currency to convert to.
    @return number The converted amount of currency.
]=]

function EconomyServer:ConvertCurrency(player : Player, amount : number, fromCurrency : Currency, toCurrency : Currency) : number
	assert(player, string.format("Invalid argument, got `%s` expected `%s`.", typeof(player) or "nil", "player"))
	assert(amount, string.format("Invalid argument, got `%s` expected `%s`.", typeof(amount) or "nil", "number"))
	assert(fromCurrency, string.format("Invalid argument, got `%s` expected `%s`.", typeof(fromCurrency) or "nil", "	Currency :: (currencyName, currencySymbol, currencyHolders, initialDistribution, inflationRate)"))
	assert(toCurrency, string.format("Invalid argument, got `%s` expected `%s`.", typeof(toCurrency) or "nil", "	Currency :: (currencyName, currencySymbol, currencyHolders, initialDistribution, inflationRate)"))
	
    local exchangeRate = self:GetExchangeRate(fromCurrency, toCurrency)
    assert(exchangeRate, "Exchange rate not found.")

    local newAmount : number = amount * exchangeRate
	self:AssignCurrency(player :: Player, toCurrency :: Currency, newAmount :: number)
	self:AssignCurrency(player :: Player, toCurrency :: Currency, newAmount :: number)
end

--[=[
    Retrieves the exchange rate between two currencies.
    @param fromCurrency Currency The currency to convert from.
    @param toCurrency Currency The currency to convert to.
    @return number The exchange rate between the two currencies.
]=]

function EconomyServer:GetExchangeRate(fromCurrency : Currency, toCurrency : Currency) : number
    assert(self[fromCurrency], "Selected currency not found.")
	assert(self[toCurrency], "Target currency not found.")

    local fromInflationRate = fromCurrency.inflationRate or 0
    local toInflationRate = toCurrency.inflationRate or 0

    local averageInflationRate = (fromInflationRate + toInflationRate) / 2
    local exchangeRate = 1 / (1 + averageInflationRate)

    return exchangeRate
end

--[=[
    Assigns a specific amount of currency to a player.
    @param player Player The player to whom the currency is assigned.
    @param selectedCurrency Currency The type of currency being assigned.
    @param holdingAmount number The amount of currency to assign.
    @return boolean true if the assignment was successful, false otherwise.
]=]

function EconomyServer:AssignCurrency(player : Player, selectedCurrency : Currency, holdingAmount : number) : boolean
	assert(player, string.format("Invalid argument, got `%s` expected `%s`.", typeof(player) or "nil", "player"))
	assert(selectedCurrency, string.format("Invalid argument, got `%s` expected `%s`.", typeof(selectedCurrency) or "nil", "	Currency :: (currencyName, currencySymbol, currencyHolders, initialDistribution, inflationRate)"))
	assert(holdingAmount, string.format("Invalid argument, got `%s` expected `%s`.", typeof(holdingAmount) or "nil", "number"))
	assert(self[selectedCurrency], "Selected currency not found")
	assert(self[selectedCurrency].currencyHolders[player], "Player doens't hold selected currency")


end

return EconomyServer