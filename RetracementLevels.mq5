//+------------------------------------------------------------------+
//|                                             RetracementLevels.mq5 |
//|                                                    Roshane Forde |
//|                                        https://roshaneforde.com/ |
//+------------------------------------------------------------------+
#property copyright "Roshane Forde"
#property link "https://roshaneforde.com/"
#property version "1.04"
#property indicator_chart_window

#property indicator_buffers 4;
#property indicator_plots   4;
#property indicator_type1   DRAW_NONE;

enum DrawOn {
  LAST_CANDLE,
  LAST_THREE_CANDLES,
  LAST_FIVE_CANDLES,
  LAST_TWENTY_CANDLES,
  LAST_ONE_HUNDRED_CANDLES
};

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
input DrawOn drawOn = LAST_CANDLE; // Draw On

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

input YesNo testMode = NO; // Test Mode (For Backtesting)

double lineOneRetracementLevelBuffer[];
double lineTwoRetracementLevelBuffer[];
double lineThreeRetracementLevelBuffer[];
double lineFourRetracementLevelBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
  SetIndexBuffer(0, lineOneRetracementLevelBuffer, INDICATOR_DATA);
  SetIndexBuffer(1, lineTwoRetracementLevelBuffer, INDICATOR_DATA);
  SetIndexBuffer(2, lineThreeRetracementLevelBuffer, INDICATOR_DATA);
  SetIndexBuffer(3, lineFourRetracementLevelBuffer, INDICATOR_DATA);

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

  // Number of candles
  int totalCandles = rates_total - 2;

  // Draw on the last three candles
  if (drawOn == LAST_THREE_CANDLES && rates_total > 4) {
    totalCandles = rates_total - 4;
  }

  // Draw on the last five candles
  if (drawOn == LAST_FIVE_CANDLES && rates_total > 6) {
    totalCandles = rates_total - 6;
  }

  // Draw on the last twenty candles
  if (drawOn == LAST_TWENTY_CANDLES && rates_total > 21) {
    totalCandles = rates_total - 21;
  }

  // Draw on the last one hundred candles
  if (drawOn == LAST_ONE_HUNDRED_CANDLES && rates_total > 101) {
    totalCandles = rates_total - 101;
  }

  // Remove all retracement ojects
  removeRetracementOjects();

  // Draw objects for current chart
  if (drawOnCurrentChart == YES) {
    for (int i = totalCandles; i < rates_total; i++) {
      drawRetracementOjects(i, time, open, high, low, close, rates_total);
    }
  }

  // Draw objects for higher timeframe
  if (drawHigherTimeframe == YES) {
    drawHigherTimeframeObjects();
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
  
  lineOneRetracementLevelBuffer[i] = lineOneRetracementLevel;
  lineTwoRetracementLevelBuffer[i] = lineTwoRetracementLevel;
  lineThreeRetracementLevelBuffer[i] = lineThreeRetracementLevel;
  lineFourRetracementLevelBuffer[i] = lineFourRetracementLevel;

  // Define a unique name for each object
  string lineOneName = "RetracementLineOne_" + IntegerToString(i);
  string lineTwoName = "RetracementLineTwo_" + IntegerToString(i);
  string lineThreeName = "RetracementLineThree_" + IntegerToString(i);
  string lineFourName = "RetracementLineFour_" + IntegerToString(i);
  string rectangleName = "HighlightedArea_" + IntegerToString(i);

  // Delete the object if it already exists (to prevent duplicates)
  if (ObjectFind(0, lineOneName) != -1) {
    ObjectDelete(0, lineOneName);
  }

  if (ObjectFind(0, lineTwoName) != -1) {
    ObjectDelete(0, lineTwoName);
  }

  if (ObjectFind(0, lineThreeName) != -1) {
    ObjectDelete(0, lineThreeName);
  }

  if (ObjectFind(0, lineFourName) != -1) {
    ObjectDelete(0, lineFourName);
  }

  if (ObjectFind(0, rectangleName) != -1) {
    ObjectDelete(0, rectangleName);
  }

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
void drawHigherTimeframeObjects()
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
  double previousCandleOpen = iOpen(_Symbol, timeframe, 1);
  double previousCandleLow = iLow(_Symbol, timeframe, 1);
  double previousCandleHigh = iHigh(_Symbol, timeframe, 1);
  double previousCandleClose = iClose(_Symbol, timeframe, 1);

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

  // Define a unique name for each object
  string lineOneName = "HigherTimeframeRetracementLineOne";
  string lineTwoName = "HigherTimeframeRetracementLineTwo";
  string lineThreeName = "HigherTimeframeRetracementLineThree";
  string lineFourName = "HigherTimeframeRetracementLineFour";
  string rectangleName = "HigherTimeframeHighlightedArea";
  
  // Create the object on the current chart but use higher timeframe data
  datetime time1 = iTime(_Symbol, timeframe, 1);
  double priceLevel = iClose(_Symbol, timeframe, 1);

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
  ObjectCreate(0, lineOneName, OBJ_TREND, 0, time1, lineOneRetracementLevel, time1 + time2, lineOneRetracementLevel);
  ObjectSetInteger(0, lineOneName, OBJPROP_COLOR, lineTwoColor);
  ObjectSetInteger(0, lineOneName, OBJPROP_WIDTH, lineTwoWidth);
  ObjectSetInteger(0, lineOneName, OBJPROP_STYLE, lineTwoStyle);

  ObjectCreate(0, lineTwoName, OBJ_TREND, 0, time1, lineTwoRetracementLevel, time1 + time2, lineTwoRetracementLevel);
  ObjectSetInteger(0, lineTwoName, OBJPROP_COLOR, lineTwoColor);
  ObjectSetInteger(0, lineTwoName, OBJPROP_WIDTH, lineTwoWidth);
  ObjectSetInteger(0, lineTwoName, OBJPROP_STYLE, lineTwoStyle);

  ObjectCreate(0, lineThreeName, OBJ_TREND, 0, time1, lineThreeRetracementLevel, time1 + time2, lineThreeRetracementLevel);
  ObjectSetInteger(0, lineThreeName, OBJPROP_COLOR, lineThreeColor);
  ObjectSetInteger(0, lineThreeName, OBJPROP_WIDTH, lineThreeWidth);
  ObjectSetInteger(0, lineThreeName, OBJPROP_STYLE, lineThreeStyle);

  ObjectCreate(0, lineFourName, OBJ_TREND, 0, time1, lineFourRetracementLevel, time1 + time2, lineFourRetracementLevel);
  ObjectSetInteger(0, lineFourName, OBJPROP_COLOR, lineFourColor);
  ObjectSetInteger(0, lineFourName, OBJPROP_WIDTH, lineFourWidth);
  ObjectSetInteger(0, lineFourName, OBJPROP_STYLE, lineFourStyle);

  // Highlight the area between Line Two and Line Three with a rectangle
  ObjectCreate(0, rectangleName, OBJ_RECTANGLE, 0, time1, lineTwoRetracementLevel, time1 + time2, lineFourRetracementLevel);
  ObjectSetInteger(0, rectangleName, OBJPROP_COLOR, rectangleColor);
  ObjectSetInteger(0, rectangleName, OBJPROP_BORDER_TYPE, 1);
  ObjectSetInteger(0, rectangleName, OBJPROP_BORDER_COLOR, rectangleColor);
  ObjectSetInteger(0, rectangleName, OBJPROP_FILL, true);
}

//+------------------------------------------------------------------+
//| Remove all retracement Ojects                                    |
//+------------------------------------------------------------------+
void removeRetracementOjects()
{
  for (int i = ObjectsTotal(0); i >= 0; i--) {
    string name = ObjectName(0,i);
    
    if (StringFind(name, "RetracementLineOne_") == 0) {
      ObjectDelete(0,name);
    }

    if (StringFind(name, "RetracementLineTwo_") == 0) {
      ObjectDelete(0,name);
    }

    if (StringFind(name, "RetracementLineThree_") == 0) {
      ObjectDelete(0,name);
    }

    if (StringFind(name, "RetracementLineFour_") == 0) {
      ObjectDelete(0,name);
    }

    if (StringFind(name, "HighlightedArea_") == 0) {
      ObjectDelete(0,name);
    }

    if (StringFind(name, "HigherTimeframeRetracementLineOne") == 0) {
      ObjectDelete(0,name);
    }

    if (StringFind(name, "HigherTimeframeRetracementLineTwo") == 0) {
      ObjectDelete(0,name);
    }

    if (StringFind(name, "HigherTimeframeRetracementLineThree") == 0) {
      ObjectDelete(0,name);
    }

    if (StringFind(name, "HigherTimeframeRetracementLineFour") == 0) {
      ObjectDelete(0,name);
    }

    if (StringFind(name, "HigherTimeframeHighlightedArea") == 0) {
      ObjectDelete(0,name);
    }
  }
}
