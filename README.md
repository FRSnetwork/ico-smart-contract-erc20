# ico-smart-contract-erc20
Basic ICO erc20 ethereum smart-contract

33,000,000 tokens total

rate 1ETH = 1250 tokens

minimum buy = 0.0008 ETH

to make payout owner should execute requestPayout with amount

to change discount owner should execute changePercent with new discount

to stop sale owner should execute changeState with 1

# buy tokens
When somebody send money to such contract, he/she gets(if sale isn't stopped) erc20 tokens by rate with bonus(depends on percent)
