//+------------------------------------------------------------------+
//|                                             RetracementLevels.mq5 |
//|                                                    Roshane Forde |
//|                                        https://roshaneforde.com/ |
//+------------------------------------------------------------------+
#property copyright "Roshane Forde"
#property link "https://roshaneforde.com/"
#property version "1.04"
#property indicator_chart_window

#property indicator_buffers 8;
#property indicator_plots   8;
#property indicator_type1   DRAW_NONE;

enum YesNo {
  YES,
  NO
};

enum HigherTimeframe {
  W1,
  D1,
  H12,
  H4
};

input YesNo drawOnCurrentChart = YES; // Draw On Current Chart

input YesNo drawLineOne = YES; // Draw Line One
input double lineOneRetracementPercentage = 0.236; // Line One Retracement Percentage
input color lineOneColor = clrDodgerBlue; // Line One Color
input ENUM_LINE_STYLE lineOneStyle = STYLE_DOT; // Line One Style
input int lineOneWidth = 1; // Line One Width

input YesNo drawLineTwo = YES; // Draw Line Two
input double lineTwoRetracementPercentage = 0.382; // Line Two Retracement Percentage
input color lineTwoColor = clrDodgerBlue; // Line Two Color
input ENUM_LINE_STYLE lineTwoStyle = STYLE_DOT; // Line Two Style
input int lineTwoWidth = 1; // Line Two Width

input YesNo drawLineThree = YES; // Draw Line Three
input double lineThreeRetracementPercentage = 0.500; // Line Three Retracement Percentage
input color lineThreeColor = clrDodgerBlue; // Line Three Color
input ENUM_LINE_STYLE lineThreeStyle = STYLE_DOT; // Line Three Style
input int lineThreeWidth = 1; // Line Three Width

input YesNo drawLineFour = YES; // Draw Line Four
input double lineFourRetracementPercentage = 0.618; // Line Four Retracement Percentage
input color lineFourColor = clrDodgerBlue; // Line Four Color
input ENUM_LINE_STYLE lineFourStyle = STYLE_DOT; // Line Four Style
input int lineFourWidth = 1; // Line Four Width

input YesNo drawRectangle = YES; // Draw Rectangle
input color rectangleColor = clrYellow; // Rectangle Color

input YesNo drawHigherTimeframe = YES; // Draw Levels On Higher Timeframe
input HigherTimeframe higherTimeframe = H12; // Higher Timeframe

input YesNo drawHTLineOne = YES; // Draw Higher Timeframe Line One
input color htLineOneColor = clrDodgerBlue; // Higher Timeframe Line One Color
input ENUM_LINE_STYLE htLineOneStyle = STYLE_DOT; // Higher Timeframe Line One Style
input int htLineOneWidth = 1; // Higher Timeframe Line One Width

input YesNo drawHTLineTwo = YES; // Draw Higher Timeframe Line Two
input color htLineTwoColor = clrDodgerBlue; // Higher Timeframe Line Two Color
input ENUM_LINE_STYLE htLineTwoStyle = STYLE_DOT; // Higher Timeframe Line Two Style
input int htLineTwoWidth = 1; // Higher Timeframe Line Two Width

input YesNo drawHTLineThree = YES; // Draw Higher Timeframe Line Three
input color htLineThreeColor = clrDodgerBlue; // Higher Timeframe Line Three Color
input ENUM_LINE_STYLE htLineThreeStyle = STYLE_DOT; // Higher Timeframe Line Three Style
input int htLineThreeWidth = 1; // Higher Timeframe Line Three Width

input YesNo drawHTLineFour = YES; // Draw Higher Timeframe Line Four
input color htLineFourColor = clrDodgerBlue; // Higher Timeframe Line Four Color
input ENUM_LINE_STYLE htLineFourStyle = STYLE_DOT; // Higher Timeframe Line Four Style
input int htLineFourWidth = 1; // Higher Timeframe Line Four Width

input YesNo drawHTRectangle = YES; // Draw Higher Timeframe Rectangle
input color htRectangleColor = clrYellow; // Higher Timeframe Rectangle Color

input YesNo testMode = NO; // Test Mode (For Backtesting)

// Lower timeframe buffers
double lineOneBuffer[];
double lineTwoBuffer[];
double lineThreeBuffer[];
double lineFourBuffer[];

// Higher timeframe buffers
double higherTimeframeLineOneBuffer[];
double higherTimeframeLineTwoBuffer[];
double higherTimeframeLineThreeBuffer[];
double higherTimeframeLineFourBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
  SetIndexBuffer(0, lineOneBuffer, INDICATOR_DATA);
  SetIndexBuffer(1, lineTwoBuffer, INDICATOR_DATA);
  SetIndexBuffer(2, lineThreeBuffer, INDICATOR_DATA);
  SetIndexBuffer(3, lineFourBuffer, INDICATOR_DATA);

  SetIndexBuffer(4, higherTimeframeLineOneBuffer, INDICATOR_DATA);
  SetIndexBuffer(5, higherTimeframeLineTwoBuffer, INDICATOR_DATA);
  SetIndexBuffer(6, higherTimeframeLineThreeBuffer, INDICATOR_DATA);
  SetIndexBuffer(7, higherTimeframeLineFourBuffer, INDICATOR_DATA);

  return (INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
  
  // Only run if new candles are available
  if (rates_total <= prev_calculated) {
    return (rates_total);
  }

  // Remove all retracement ojects
  removeRetracementOjects();

  // Draw objects for current chart
  if (drawOnCurrentChart == YES) {
    // Number of candles
    int totalCandles = rates_total - 2;

    // Test Mode - Draw on the last 100 candles
    if (rates_total > 101 && testMode == YES) {
      totalCandles = rates_total - 101;
    }

    for (int i = totalCandles; i < rates_total; i++) {
      drawRetracementOjects(i, time, open, high, low, close, rates_total);
    }
  }

  // Draw objects for higher timeframe
  if (drawHigherTimeframe == YES) {
    
    int totalHigherTimeframeCandles = 1;

    // Test Mode - Draw on the last 100 candles
    if (testMode == YES) {
      totalHigherTimeframeCandles = 100;
    }

    for (int i = 1; i <= totalHigherTimeframeCandles; i++) {
      drawHigherTimeframeObjects(i);
    }
  }

  return (rates_total);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
  removeRetracementOjects();
}

//+------------------------------------------------------------------+
//| Draw retracement objects                                         |
//+------------------------------------------------------------------+
void drawRetracementOjects(int i, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[], const int rates_total)
{
  // Retracement levels
  double lineOneRetracementLevel = 0;
  double lineTwoRetracementLevel = 0;
  double lineThreeRetracementLevel = 0;
  double lineFourRetracementLevel = 0;

  // If previous candle is bullish
  if (close[i] > open[i]) {
    lineOneRetracementLevel = high[i] - ((high[i] - low[i]) * lineOneRetracementPercentage);
    lineTwoRetracementLevel = high[i] - ((high[i] - low[i]) * lineTwoRetracementPercentage);
    lineThreeRetracementLevel = high[i] - ((high[i] - low[i]) * lineThreeRetracementPercentage);
    lineFourRetracementLevel = high[i] - ((high[i] - low[i]) * lineFourRetracementPercentage);
  }

  // If previous candle is bearish
  if (close[i] < open[i]) {
    lineOneRetracementLevel = low[i] + ((high[i] - low[i]) * lineOneRetracementPercentage);
    lineTwoRetracementLevel = low[i] + ((high[i] - low[i]) * lineTwoRetracementPercentage);
    lineThreeRetracementLevel = low[i] + ((high[i] - low[i]) * lineThreeRetracementPercentage);
    lineFourRetracementLevel = low[i] + ((high[i] - low[i]) * lineFourRetracementPercentage);
  }
  
  lineOneBuffer[i] = lineOneRetracementLevel;
  lineTwoBuffer[i] = lineTwoRetracementLevel;
  lineThreeBuffer[i] = lineThreeRetracementLevel;
  lineFourBuffer[i] = lineFourRetracementLevel;

  // Define a unique name for each object
  string lineOneName = "RetracementLineOne_" + IntegerToString(i);
  string lineTwoName = "RetracementLineTwo_" + IntegerToString(i);
  string lineThreeName = "RetracementLineThree_" + IntegerToString(i);
  string lineFourName = "RetracementLineFour_" + IntegerToString(i);
  string rectangleName = "HighlightedArea_" + IntegerToString(i);

  // Test Mode - Draw on continuation candles only
  if (testMode == YES) {
    if ((i + 1 < rates_total) && close[i] > open[i] && close[i + 1] < open[i + 1]) {
      return;
    }

    if ((i + 1 < rates_total) && close[i] < open[i] && close[i + 1] > open[i + 1]) {
      return;
    }
  }
  
  // Draw objects extending to the next candle's position
  if (i < rates_total - 1) {

    if (drawLineOne == YES) {
      ObjectCreate(0, lineOneName, OBJ_TREND, 0, time[i], lineOneRetracementLevel, time[i + 1], lineOneRetracementLevel);
      ObjectSetInteger(0, lineOneName, OBJPROP_COLOR, lineOneColor);
      ObjectSetInteger(0, lineOneName, OBJPROP_WIDTH, lineOneWidth);
      ObjectSetInteger(0, lineOneName, OBJPROP_STYLE, lineOneStyle);
    }

    if (drawLineTwo == YES) {
      ObjectCreate(0, lineTwoName, OBJ_TREND, 0, time[i], lineTwoRetracementLevel, time[i + 1], lineTwoRetracementLevel);
      ObjectSetInteger(0, lineTwoName, OBJPROP_COLOR, lineTwoColor);
      ObjectSetInteger(0, lineTwoName, OBJPROP_WIDTH, lineTwoWidth);
      ObjectSetInteger(0, lineTwoName, OBJPROP_STYLE, lineTwoStyle);
    }

    if (drawLineThree == YES) {
      ObjectCreate(0, lineThreeName, OBJ_TREND, 0, time[i], lineThreeRetracementLevel, time[i + 1], lineThreeRetracementLevel);
      ObjectSetInteger(0, lineThreeName, OBJPROP_COLOR, lineThreeColor);
      ObjectSetInteger(0, lineThreeName, OBJPROP_WIDTH, lineThreeWidth);
      ObjectSetInteger(0, lineThreeName, OBJPROP_STYLE, lineThreeStyle);
    }

    if (drawLineFour == YES) {
      ObjectCreate(0, lineFourName, OBJ_TREND, 0, time[i], lineFourRetracementLevel, time[i + 1], lineFourRetracementLevel);
      ObjectSetInteger(0, lineFourName, OBJPROP_COLOR, lineFourColor);
      ObjectSetInteger(0, lineFourName, OBJPROP_WIDTH, lineFourWidth);
      ObjectSetInteger(0, lineFourName, OBJPROP_STYLE, lineFourStyle);
    }

    // Highlight the area between Line Two and Line Four with a rectangle
    if (drawRectangle == YES) {
      ObjectCreate(0, rectangleName, OBJ_RECTANGLE, 0, time[i], lineTwoRetracementLevel, time[i + 1], lineFourRetracementLevel);
      ObjectSetInteger(0, rectangleName, OBJPROP_COLOR, rectangleColor);
      ObjectSetInteger(0, rectangleName, OBJPROP_BORDER_TYPE, 1);
      ObjectSetInteger(0, rectangleName, OBJPROP_BORDER_COLOR, rectangleColor);
      ObjectSetInteger(0, rectangleName, OBJPROP_FILL, true);
    }
  }
}

//+------------------------------------------------------------------+
//| Draw object on higher timeframe                                  |
//+------------------------------------------------------------------+
void drawHigherTimeframeObjects(int i)
{
  // Store timeframe
  ENUM_TIMEFRAMES timeframe = PERIOD_H12;

  if (higherTimeframe == W1) {
    timeframe = PERIOD_W1;
  }

  if (higherTimeframe == D1) {
    timeframe = PERIOD_D1;
  }

  if (higherTimeframe == H12) {
    timeframe = PERIOD_H12;
  }

  if (higherTimeframe == H4) {
    timeframe = PERIOD_H4;
  }

  // Previous candle data
  double previousCandleOpen = iOpen(_Symbol, timeframe, i);
  double previousCandleLow = iLow(_Symbol, timeframe, i);
  double previousCandleHigh = iHigh(_Symbol, timeframe, i);
  double previousCandleClose = iClose(_Symbol, timeframe, i);

  // Retracement levels
  double lineOneRetracementLevel = 0;
  double lineTwoRetracementLevel = 0;
  double lineThreeRetracementLevel = 0;
  double lineFourRetracementLevel = 0;

  // If previous candle is bullish
  if (previousCandleClose > previousCandleOpen) {
    lineOneRetracementLevel = previousCandleHigh - ((previousCandleHigh - previousCandleLow) * lineOneRetracementPercentage);
    lineTwoRetracementLevel = previousCandleHigh - ((previousCandleHigh - previousCandleLow) * lineTwoRetracementPercentage);
    lineThreeRetracementLevel = previousCandleHigh - ((previousCandleHigh - previousCandleLow) * lineThreeRetracementPercentage);
    lineFourRetracementLevel = previousCandleHigh - ((previousCandleHigh - previousCandleLow) * lineFourRetracementPercentage);
  }

  // If previous candle is bearish
  if (previousCandleClose < previousCandleOpen) {
    lineOneRetracementLevel = previousCandleLow + ((previousCandleHigh - previousCandleLow) * lineOneRetracementPercentage);
    lineTwoRetracementLevel = previousCandleLow + ((previousCandleHigh - previousCandleLow) * lineTwoRetracementPercentage);
    lineThreeRetracementLevel = previousCandleLow + ((previousCandleHigh - previousCandleLow) * lineThreeRetracementPercentage);
    lineFourRetracementLevel = previousCandleLow + ((previousCandleHigh - previousCandleLow) * lineFourRetracementPercentage);
  }

  higherTimeframeLineOneBuffer[i] = lineOneRetracementLevel;
  higherTimeframeLineTwoBuffer[i] = lineTwoRetracementLevel;
  higherTimeframeLineThreeBuffer[i] = lineThreeRetracementLevel;
  higherTimeframeLineFourBuffer[i] = lineFourRetracementLevel;

  // Define a unique name for each object
  string lineOneName = "HigherTimeframeRetracementLineOne_" + IntegerToString(i);
  string lineTwoName = "HigherTimeframeRetracementLineTwo_" + IntegerToString(i);
  string lineThreeName = "HigherTimeframeRetracementLineThree_" + IntegerToString(i);
  string lineFourName = "HigherTimeframeRetracementLineFour_" + IntegerToString(i);
  string rectangleName = "HigherTimeframeHighlightedArea_" + IntegerToString(i);

  // Test Mode - Draw on continuation candles only
  if (testMode == YES) {
    if ((i <= 100) && previousCandleClose > previousCandleOpen && iClose(_Symbol, timeframe, i - 1) < iOpen(_Symbol, timeframe, i - 1)) {
      return;
    }

    if ((i <= 100) && previousCandleClose < previousCandleOpen && iClose(_Symbol, timeframe, i - 1) > iOpen(_Symbol, timeframe, i - 1)) {
      return;
    }
  }
  
  // Create the object on the current chart but use higher timeframe data
  datetime time1 = iTime(_Symbol, timeframe, i);
  double priceLevel = iClose(_Symbol, timeframe, i);

  // Time to extend the line to
  double time2 = 0;

  if (higherTimeframe == W1) {
    time2 = 1209600; // 2 weeks
  }

  if (higherTimeframe == D1) {
    time2 = 172800; // 2 days
  }

  if (higherTimeframe == H12) {
    time2 = 86400; // 1 day
  }

  if (higherTimeframe == H4) {
    time2 = 28800; // 8 hours
  }

  // Draw lines extending to the next candle's position
  if (drawHTLineOne == YES) {
    ObjectCreate(0, lineOneName, OBJ_TREND, 0, time1, lineOneRetracementLevel, time1 + time2, lineOneRetracementLevel);
    ObjectSetInteger(0, lineOneName, OBJPROP_COLOR, htLineOneColor);
    ObjectSetInteger(0, lineOneName, OBJPROP_WIDTH, htLineOneWidth);
    ObjectSetInteger(0, lineOneName, OBJPROP_STYLE, htLineOneStyle);
  }
  
  if (drawHTLineTwo == YES) {
    ObjectCreate(0, lineTwoName, OBJ_TREND, 0, time1, lineTwoRetracementLevel, time1 + time2, lineTwoRetracementLevel);
    ObjectSetInteger(0, lineTwoName, OBJPROP_COLOR, htLineTwoColor);
    ObjectSetInteger(0, lineTwoName, OBJPROP_WIDTH, htLineTwoWidth);
    ObjectSetInteger(0, lineTwoName, OBJPROP_STYLE, htLineTwoStyle);
  }
  
  if (drawHTLineThree == YES) {
    ObjectCreate(0, lineThreeName, OBJ_TREND, 0, time1, lineThreeRetracementLevel, time1 + time2, lineThreeRetracementLevel);
    ObjectSetInteger(0, lineThreeName, OBJPROP_COLOR, htLineThreeColor);
    ObjectSetInteger(0, lineThreeName, OBJPROP_WIDTH, htLineThreeWidth);
    ObjectSetInteger(0, lineThreeName, OBJPROP_STYLE, htLineThreeStyle);
  }


  if (drawHTLineFour == YES) {
    ObjectCreate(0, lineFourName, OBJ_TREND, 0, time1, lineFourRetracementLevel, time1 + time2, lineFourRetracementLevel);
    ObjectSetInteger(0, lineFourName, OBJPROP_COLOR, htLineFourColor);
    ObjectSetInteger(0, lineFourName, OBJPROP_WIDTH, htLineFourWidth);
    ObjectSetInteger(0, lineFourName, OBJPROP_STYLE, htLineFourStyle);
  }

  // Highlight the area between Line Two and Line Three with a rectangle
  if (drawHTRectangle == YES) {
    ObjectCreate(0, rectangleName, OBJ_RECTANGLE, 0, time1, lineTwoRetracementLevel, time1 + time2, lineFourRetracementLevel);
    ObjectSetInteger(0, rectangleName, OBJPROP_COLOR, htRectangleColor);
    ObjectSetInteger(0, rectangleName, OBJPROP_BORDER_TYPE, 1);
    ObjectSetInteger(0, rectangleName, OBJPROP_BORDER_COLOR, htRectangleColor);
    ObjectSetInteger(0, rectangleName, OBJPROP_FILL, true);
  }
}

//+------------------------------------------------------------------+
//| Remove all retracement Ojects                                    |
//+------------------------------------------------------------------+
void removeRetracementOjects()
{
  for (int i = ObjectsTotal(0); i >= 0; i--) {
    string name = ObjectName(0, i);

    if (StringFind(name, "RetracementLineOne_") == 0) {
      ObjectDelete(0, name);
    }

    if (StringFind(name, "RetracementLineTwo_") == 0) {
      ObjectDelete(0, name);
    }

    if (StringFind(name, "RetracementLineThree_") == 0) {
      ObjectDelete(0, name);
    }

    if (StringFind(name, "RetracementLineFour_") == 0) {
      ObjectDelete(0, name);
    }

    if (StringFind(name, "HighlightedArea_") == 0) {
      ObjectDelete(0, name);
    }

    if (StringFind(name, "HigherTimeframeRetracementLineOne_") == 0) {
      ObjectDelete(0, name);
    }

    if (StringFind(name, "HigherTimeframeRetracementLineTwo_") == 0) {
      ObjectDelete(0, name);
    }

    if (StringFind(name, "HigherTimeframeRetracementLineThree_") == 0) {
      ObjectDelete(0, name);
    }

    if (StringFind(name, "HigherTimeframeRetracementLineFour_") == 0) {
      ObjectDelete(0, name);
    }

    if (StringFind(name, "HigherTimeframeHighlightedArea_") >= 0) {
      ObjectDelete(0, name);
    }
  }

  if (StringFind( ObjectName(0, 1), "HigherTimeframeHighlightedArea_") >= 0) {
      ObjectDelete(0, "HigherTimeframeHighlightedArea_1");
  }
}
