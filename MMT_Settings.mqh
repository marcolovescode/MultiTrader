//+------------------------------------------------------------------+
//|                                    MultiTrader Main Settings.mqh |
//|                                          Copyright 2017, Marco Z |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Marco Z"
#property link      "https://www.mql5.com"
#property strict

#include "MC_Common/MC_Error.mqh"

enum TimeUnits {
    UnitSeconds // Seconds
    , UnitMilliseconds // Milliseconds
    //, UnitMicroseconds // Microseconds
    , UnitTicks // Ticks: Applies only in tick mode
};

enum BalanceUnits {
    UnitAccountCurrency // Account currency
    , UnitPips // Pips
};

enum CalcMethod {
    CalcValue // Use exact value below
    , CalcFilterExact // Use exact value from filter
    , CalcFilterFactor // Factor value from filter
};

enum CycleType {
    CycleTimerSeconds           // Seconds: Run on a second-based interval
    , CycleTimerMilliseconds    // Milliseconds: Run on a millisecond-based interval
    , CycleTimerTicks           // Average ticks: Run on an average tick interval
    , CycleRealTicks            // Real ticks: Run on every tick; applies only in Single Symbol Mode
};

enum TradeMode {
    TradeMarket           // Trade with normal market orders
    , TradeLimitOrders    // Trade with pending limit orders
    , TradeGrid           // Trade with grid orders
};

enum OrderProfitType {
    OrderBothProfitLoss    // All orders
    , OrderOnlyProfitable  // Profitable orders only
    , OrderOnlyLoss        // Losing orders only
};

enum OrderOpType {
    OrderBothLongShort     // All orders
    , OrderOnlyLong        // Long positions only
    , OrderOnlyShort       // Short positions only
};

extern string LblRuntime="********** Runtime Settings **********";
extern int MagicNumber=5001;
extern string ConfigComment=""; // ConfigComment: Comment to display on dashboard

extern string Lbl_ErrorSettings="---- Error Settings ----";
extern ErrorLevelConfig ErrorTerminalLevel=ErrorConfigFatalNormal; // ErrorTerminalLevel: Errors to show in terminal
extern ErrorLevelConfig ErrorFileLevel=ErrorConfigNone; // ErrorFileLevel: Errors to write to log file (Hide=Disable)
extern ErrorLevelConfig ErrorAlertLevel=ErrorConfigFatal; // ErrorAlertLevel: Errors to trigger an alert
extern string ErrorLogFileName=""; // ErrorLogFileName: Leave blank to generate a filename    
//extern int HistoryLevel=1; // HistoryLevel: Number of filter values to keep in memory
int DataHistoryLevel=1; // not convinced this should be a user setting
int SignalHistoryLevel=3;

//
//extern string Lbl_Notification="---- Notification Settings ----";
//extern bool PopupAlert=false;
//extern bool EmailAlert=false;
//extern bool PushAlert=false;

extern string LblDisplay="---- Display Settings ----";
extern bool DisplayShow=true;
extern bool DisplayShowTable=true;
extern bool DisplayColor=true;
//extern bool DisplayShowOrders=true;
//extern string DisplayFont="Lucida Console";
string DisplayFont="Lucida Console"; // Integral font to monospace layout and scaling, should not be user setting
extern int DisplayScale=0; // DisplayScale: 0 = Normal, 1+ = Large
//extern int DisplayFontSize=11;
//extern int DisplaySpacing=13;
//extern DisplayStyleEnum DisplayStyle=ValueAndSignal;

extern string Lbl_CycleSettings="---- Cycle Settings ----";
extern CycleType CycleMode=CycleTimerSeconds;
extern int CycleLength=1; // CycleLength: Length between cycles (seconds or milliseconds)

extern string Lbl_Symbols="********** Symbols & Currencies Settings **********";
extern bool SingleSymbolMode=false; // SingleSymbolMode: Use only the current chart symbol
extern string IncludeSymbols="AUDCADi,AUDCHFi,AUDJPYi,AUDNZDi,AUDUSDi,CADCHFi,CADJPYi,CHFJPYi,EURAUDi,EURCADi,EURJPYi,EURNZDi,EURUSDi,EURGBPi,GBPAUDi,GBPCADi,GBPCHFi,GBPJPYi,GBPNZDi,GBPUSDi,NZDCADi,NZDCHFi,NZDJPYi,NZDUSDi,USDCADi,USDCHFi,USDJPYi";
extern string ExcludeSymbols="";
extern string ExcludeCurrencies="SEK,SGD,DKK,NOK,TRY,HKD,ZAR,MXN,XAG,XAU";

extern string Lbl_Trade="********** Trade Settings **********";
extern bool TradeEntryEnabled=true;
extern bool TradeExitEnabled=true;
extern bool TradeValueEnabled=true;

extern string Lbl_TradeGeneral="---- General Trade Settings ----";
extern TradeMode TradeModeType=TradeMarket; // TradeModeType: Type of trades to enter
extern bool BrokerTwoStep=true; // IsTwoStep: Broker is ECN and needs two-step order sending for SL/TP
extern string OrderComment_=""; // OrderComment: Comment to attach to orders
extern bool CloseOrderOnOppositeSignal=true; // CloseOrderOnOppositeSignal: Close when entry signal is opposite
extern bool SignalRetraceOpen=true; // SignalRetraceOpen: Enter additional positions on a retrace
extern int MaxTradesPerSymbol=0;
// extern int MaxTradesTimeframe=60;
extern double TradeMinMarginLevel=200; // MinTradeMarginLevel (percent)

extern string Lbl_TradeDelays="---- Trade Delay Settings ----";
extern TimeUnits TimeSettingUnit=UnitSeconds; // TimeSettingUnit: Unit for values below
extern int EntryStableTime=5;
extern int ExitStableTime=5;
extern int SignalRetraceTime=3600; // SignalRetraceTime: Repeating signal change is seen as retrace
extern int TradeBetweenDelay=0; // TradeBetweenDelay: Wait between trades
extern int ValueBetweenDelay=0; // ValueBetweenDelay: Wait between value changes

extern string Lbl_TradeSched="---- Schedule Settings ----";
extern bool SchedCloseDaily = false; // SchedCloseDaily: Exit trades before day close to prevent swap
extern bool SchedClose3DaySwap = true; // SchedClose3DaySwap: Exit trades before 3-day swap per symbol
extern bool SchedCloseOffSessions = true; // SchedCloseOffSessions: Exit trades before next session is closed
extern bool SchedCloseWeekend = true; // SchedCloseWeekend: Exit trades before weekend
extern int SchedCloseMinutes = 5; // SchedCloseMinutes: Exit X mins before session close
//extern int SchedOpenLastMinutes = 60; // SchedOpenLastMinutes: Open up to X mins before session close
extern int SchedOpenMinutesDaily = 0; 
extern int SchedOpenMinutesOffSessions = 0; 
extern int SchedOpenMinutesWeekend = 180;
extern int SchedGapIgnoreMinutes = 15; // SchedGapIgnoreMinutes: Ignore session gaps of X mins
extern OrderProfitType SchedCloseOrderProfit = OrderBothProfitLoss; // SchedCloseOrderProfit: Close only profitable or losing trades
extern OrderOpType SchedCloseOrderOp = OrderBothLongShort; // SchedCloseOrderOp: Close only longs or shorts
extern bool SchedClosePendings = true;

//extern string Lbl_TradeSchedSwap="-- Minimum Swap Closing Settings --";
//extern CalcMethod SchedMinSwapLongMethod=CalcValue; // SchedMinSwapLong: Minimum swap to close long
//extern double SchedMinSwapLongValue=-5.0; 
//extern string SchedMinSwapLongName="";
//extern double SchedMinSwapLongFactor=1.0;
//extern CalcMethod SchedMinSwapShortMethod=CalcValue;  // SchedMinSwapShort: Minimum swap to close short
//extern double SchedMinSwapShortValue=-5.0; 
//extern string SchedMinSwapShortName="";
//extern double SchedMinSwapShortFactor=1.0;
// todo: can we convert points to swap currency?
// todo: close depending on swap value: does order profit exceed current swap value? compare to some filter value like ATR?
    // track separately for longs and shorts -- swap can vary widely

//
//extern string LbL_Exit_ExpiryTrade="--- Expiry Trade Exit Settings ---";
//extern bool ExpireTrades=false;
//extern int Exit_expirySeconds=900;
//
extern string LbL_Exit_ExpiryTrade="---- Grid Settings ----"; // Grid settings: Set TradeModeType above to enable grids
extern bool GridHedging=false; // GridHedging: Set pendings in both directions 
extern bool GridCloseOrdersOnSignal = true; // GridCloseOrdersOnSignal: Close market orders upon signal
extern int GridCount=5; // GridCount: # of pendings per direction
extern CalcMethod GridDistanceCalcMethod = CalcValue;
extern double GridDistanceValue = 10; // GridDistance: Pips between pending orders
extern string GridDistanceFilterName = "";
extern double GridDistanceFilterFactor = 1.0;

extern string LbL_Exit_Basket="--- Basket Exit Settings ---";
extern BalanceUnits BasketSettingUnit=UnitPips; // BasketSettingUnit: Set SLTP according to currency or pips
extern bool BasketTotalPerDay = false; // BasketTotalPerDay: Add total of all profits during day, not just open orders
// extern int BasketPeriodLengthMinutes = 1440; // BasketPeriodLengthMinutes: Time to limit baskets
//extern bool BasketIncludeFees=false; // BasketIncludeFees: Deduct fees from profit calculation
extern bool BasketEnableStopLoss=false;
extern double BasketStopLossValue=-200.0;
extern int BasketMaxLosingPerDay=2;
// todo: basket filter values. Complicated because we may need to aggregate filters across symbols for a proper basket sltp
extern bool BasketEnableTakeProfit=false;
extern double BasketTakeProfitValue=400.0;
extern int BasketMaxWinningPerDay=1;

extern string Lbl_MaxSpread="---- Max Spread Settings ----";
extern CalcMethod MaxSpreadCalcMethod=CalcValue;
extern double MaxSpreadValue=4.0; 
extern string MaxSpreadFilterName="";
extern double MaxSpreadFilterFactor=1.0;

extern string Lbl_MaxSlippage="---- Max Slippage Settings ----";
extern CalcMethod MaxSlippageCalcMethod=CalcValue;
extern double MaxSlippageValue=4.0; 
extern string MaxSlippageFilterName="";
extern double MaxSlippageFilterFactor=1.0;

extern string Lbl_LotSize="---- Lot Size Settings ----";
extern CalcMethod LotSizeCalcMethod=CalcValue;
extern double LotSizeValue=0.1;
extern string LotSizeFilterName="";
extern double LotSizeFilterFactor=1.0;

extern string Lbl_StopLoss="---- Stop Loss Settings ----";
extern bool StopLossEnabled=false;
extern bool StopLossBroker=true; // StopLossBroker: Send SL to broker
extern bool StopLossInternal=true; // StopLossInternal: Track and fire SL using EA
extern double StopLossBrokerFactor=1.0; // StopLossBrokerFactor: Factor broker SL if Internal enabled
extern CalcMethod StopLossCalcMethod=CalcValue;
extern double StopLossValue=-30.0;
extern string StopLossFilterName="";
extern double StopLossFilterFactor=-1.0;

extern string Lbl_TakeProfit="---- Take Profit Settings ----";
extern bool TakeProfitEnabled=false;
extern bool TakeProfitBroker=true; // TakeProfitBroker: Send TP to broker
extern bool TakeProfitInternal=true; // TakeProfitInternal: Track and fire TP using EA
extern double TakeProfitBrokerFactor=1.0; // TakeProfitBrokerFactor: Factor broker TP if Internal enabled
extern CalcMethod TakeProfitCalcMethod=CalcValue;
extern double TakeProfitValue=30.0;
extern string TakeProfitFilterName="";
extern double TakeProfitFilterFactor=1.0;

extern string Lbl_BreakEven="---- Break Even Settings ----";
extern bool BreakEvenEnabled=false;
extern double BreakEvenProfit=5.0; // BreakEvenProfit: Offset from breakeven to allow a certain profit.
extern CalcMethod BreakEvenCalcMethod=CalcValue;
extern double BreakEvenValue=10.0;
extern string BreakEvenFilterName="";
extern double BreakEvenFilterFactor=1.0;

//
//extern string Lbl_ITSL="---- Instant Trailing Stop Loss Settings ----";
//extern bool UseInstantTrailingStop=false;
//extern int TrailStopCalcMethod=0; //TrailStopCalcMethod //enum
//extern double InstantTrailingStop=30.0;
//extern double PipIncrement=5;
//
//extern string Lbl_TSF="---- Tightening stop feature Settings ----";
//extern bool UseTigheningStop=false;
//extern int TighteningCalcMethod=0; //TighteningCalcMethod //enum
//extern double TrailAt20Percent=25.0;
//extern double TrailAt40Percent=25.0;
//extern double TrailAt60Percent=25.0;
//extern double TrailAt80Percent=15.0;

extern string Lbl_JSL="---- Jumping stop loss settings ----";
extern bool JumpingStopEnabled=false;
extern bool JumpAfterBreakEvenOnly=true;
extern CalcMethod JumpingStopCalcMethod=CalcValue;
extern double JumpingStopValue=10.0;
extern string JumpingStopFilterName="";
extern double JumpingStopFilterFilterFactor=1.0;
