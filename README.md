# Retracement Levels Indicator

The Retracement Levels Indicator is a simple indicator that displays Fibonacci retracement levels based on the high and low prices of the previous candle for a continuation trade on the next candle.

## Foundational Concepts

Before diving into the indicator, it’s essential to understand a few key concepts:

Most candles have defined wicks that show the high and low prices and a body representing the open and close prices. A candle is considered bullish (green) if the close price is higher than the open price, and bearish (red) if the close price is lower than the open price.

Whenever you place a trade you are trading one candle.

If you place a trade on the M5 (5-minute) chart, you are trading one 5-minute candle, or multiple 5-minute candles within a larger timeframe (e.g., one 1-hour candle = twelve 5-minute candles).

If you place a trade on the H1 (1-hour) chart, you're trading one 1-hour candle, or multiple 1-hour candles within a larger timeframe (e.g., one 12-hour candle = twelve 1-hour candles, or one daily candle = twenty-four 1-hour candles).

Imagine a trend on the H1 (1-hour) chart. The price experiences an impulsive move up for 8 candles, followed by a retracement down for 6 candles. The trend continues with another impulsive move up for 7 candles, and a subsequent 3-candle retracement.

If you draw Fibonacci retracement levels from the low to the high of the first impulsive move, you’ll notice the price tends to retrace to one of the key Fibonacci levels (23.6%, 38.2%, 50%, or 61.8%) before resuming the trend direction.

In this example, the trend consists of 8 + 6 + 7 + 3 = 24 H1 candles, which equals one daily candle or two H12 (12-hour) candles. You would likely draw the Fibonacci retracement levels on the first H12 candle, then take the trade on the second H12 candle in the direction of the trend for that day.

You can take this example a bit further to see that if you draw Fibonacci retracement levels on one candle. The next candle, if it is going to continue in the direction of the previous candle, its wick will often retrace to one of the Fibonacci levels, before continuing in the same direction.

## Recommended Timeframe

The indicator can be used on any timeframe, but it's recommended to use it on the H12 (12-hour) chart and take trades on the H1 (1-hour) chart.

The reasoning behind this is that the one daily candle is made up of two H12 candles. Backtesting results show that, on many instruments, about 60% of the time the second half of the day follows the direction of the first half. So there is a higher probability that if the first half of the day is bullish, the second half of the day will also be bullish.

Additionally, if the price breaks out above or below the previous day's high or low, it is likely to continue in that direction for the remainder of the day. You can easily see that on the H12 chart.

To further increase the probability of your trades, you can use the 20-period Simple Moving Average (SMA) to confirm the medium-term trend or the 5-period SMA for a shorter-term trend confirmation.

## GBPJPY Example:

If the first half of the day (the first H12 candle) is bullish, we anticipate a continuation and look for a bullish trade in the second half of the day (the second H12 candle).

**Setup:** The second H12 candle will start printing red or bearish first to print the wick, then the candle will flip green or bullish to print the body.

**Entry:** To enter a trade on that candle, you would place a buy stop at the opening price when the candle is printing bearish. When the candle flips bullish, it will trigger you into the trade for the body of the candle. Alternatively, you can drop down to the H1 timeframe and look for a trade on a bullish H1 candle when the price breaks out of the Fibonacci retracement levels.

**Stop Loss:** Stop loss should be placed below the wick of the previous H12 candle. Once the trade moves into profit and is a good distance from entry, move the stop loss to break even.

**Target:** You can take profits at the close of the current H12 candle or the next significant support or resistance level.

Example Screenshots:

## XAUUSD Example:

If the first half of the day (the first H12 candle) is bearish, we anticipate a continuation and look for a bearish trade in the second half of the day (the second H12 candle).

**Setup:** The second H12 candle will start printing green or bullish first to print the wick, then the candle will flip red or bearish to print the body.

**Entry:** To enter a trade on that candle, you would place a sell stop at the opening price when the candle is printing bullish. When the candle flips bearish, it will trigger you into the trade for the body of the candle. Alternatively, you can drop down to the H1 timeframe and look for a trade on a bearish H1 candle when the price breaks out of the Fibonacci retracement levels.

**Stop Loss:** Stop loss should be placed above the wick of the previous H12 candle. Once the trade moves into profit and is a good distance from entry, move the stop loss to break even.

**Target:** You can take profits at the close of the current H12 candle or the next significant support or resistance level.

Example Screenshots:

## Indicator Features

* Displays the Fibonacci retracement levels on the last candle, or last set of candles, for any timeframe.
* The level's percentage (23.6%, 38.2%, 50%, 61.8%) can be adjusted.
* The level's color, width, and line style can be adjusted.
* Specific Fibonacci levels can be shown or hidden.
* The golden zone (38.2% - 61.8%, or between the second and last level) can be highlighted.
* Fibonacci levels can be drawn on a higher timeframe candle, and be shown on a lower timeframe.

## Contributing
If you have suggestions, improvements, or bug fixes, I encourage you to submit pull requests. Collaboration helps make the indicator more versatile and useful for everyone. 

## Disclaimer

Any trading decisions you make are entirely your responsibility.

## License

[MIT](https://github.com/roshaneforde/retracement-levels-indicator/blob/main/LICENSE.txt).
