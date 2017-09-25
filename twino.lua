-- Inofficial Twino Extension (www.twino.eu) for MoneyMoneyApp
-- Scrapes balances from Twino and returns them as securities
--
-- Username: Username
-- Password: Password
--
-- Copyright (c) 2017 beanieboi
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

WebBanking{
  version = 1.0,
  url = "https://www.twino.eu/en",
  description = "Fetch balances from Twino and list them as securities",
  services= { "Twino Account" },
}

local currency = "EUR" -- fixme: Don't hardcode
local currencyName = "EUR" -- fixme: Don't hardcode
local connection

function SupportsBank (protocol, bankCode)
  return protocol == ProtocolWebBanking and bankCode == "Twino Account"
end

function InitializeSession (protocol, bankCode, username, username2, password, username3)
  connection = Connection()
  content, charset, mimeType = connection:request("POST",
    "https://www.twino.eu/ws/public/login", '{"name":"' .. username .. '", "password":"' .. password .. '"}', "application/json;charset=UTF-8")

  if string.match(content, '"success":false') then
      return LoginFailed
  end
end

function ListAccounts (knownAccounts)
  local account = {
    name = "Twino Summary",
    accountNumber = "Twino Summary",
    currency = currency,
    portfolio = true,
    type = "AccountTypePortfolio"
  }

  return {account}
end

function RefreshAccount (account, since)
  local s = {}
  summary = AccountSummary()

  local security = {
    name = "Account",
    price = tonumber(summary.accountValue),
    quantity = 1,
    purchasePrice = tonumber(summary.investments),
    curreny = nil,
  }

  table.insert(s, security)

  return {securities = s}
end

function EndSession ()
  connection:get("https://www.twino.eu/logout")
  return nil
end

function AccountSummary ()
  local headers = {accept = "application/json"}
  local content = connection:request(
    "GET",
    "https://www.twino.eu/ws/web/investor/my-account-summary",
    "",
    "application/json",
    headers
  )
  return JSON(content):dictionary()
end

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end
