#property copyright "Copyright 2017, Marco Z"
#property link      "https://www.mql5.com"
#property strict

enum StopLossMode {
    StopModeNormal
    , StopModeValue
    , StopModeTrailing
    , StopModeJumping
    , StopModeBreakeven
};

class OrderManager {
    public:
    OrderManager();
    ~OrderManager();
    
    void doPositions(bool firstRun);
    
    private:
    
    //+------------------------------------------------------------------+
    // General
    
    ValueLocation *stopLossLoc;
    ValueLocation *takeProfitLoc;
    ValueLocation *maxSpreadLoc;
    ValueLocation *maxSlippageLoc;
    ValueLocation *lotSizeLoc;
    ValueLocation *gridDistanceLoc;
    ValueLocation *breakEvenJumpDistanceLoc;
    ValueLocation *trailingStopLoc;
    ValueLocation *jumpingStopLoc;
    
    TimePoint *lastTradeBetween[]; // keyed by symbolId
    TimePoint *lastValueBetween[];
    
    void initValueLocations();
    ValueLocation *fillValueLocation(string location);
    ValueLocation *fillValueLocation(CalcSource calcSourceIn, double setValIn, string filterNameIn, CalcOperation opIn, double operandIn);
    
    double getValue(ValueLocation *loc, int symbolIdx);
    template <typename T>
    bool getValue(T &outVal, ValueLocation *loc, int symbolIdx);
    template <typename T>
    bool getValuePrice(T &outVal, ValueLocation *loc, int symIdx);
    template <typename T>
    bool getValuePoints(T &outVal, ValueLocation *loc, int symIdx);
    
    void setLastTimePoint(int symbolIdx, bool isLastTrade, uint millisecondsIn = 0, datetime dateTimeIn = 0, uint cyclesIn = 0);
    bool getLastTimeElapsed(int symbolIdx, bool isLastTrade, TimeUnits compareUnit, int delayCompare);
    
    double offsetValue(double value, double offset, string symName = NULL, bool offsetIsPips = true);
    double unOffsetValue(double value, double offset, string symName = NULL, bool offsetIsPips = true);
    
    //+------------------------------------------------------------------+
    // Cycle
    
    int openPendingCount[];
    int openMarketCount[];
    
    bool gridSetLong[];
    bool gridSetShort[];
    bool gridExit[];
    bool gridExitBySignal[];
    bool gridExitByOpposite[];
    
    void doCurrentPositions(bool firstRun);
    void evaluateFulfilledFromOrder(int ticket, int symbolIdx);
    bool checkDoSelectOrder(int ticket);
    void resetOpenCount();
    void addOrderToOpenCount(int ticket, int symIdx = -1);
    
    //+------------------------------------------------------------------+
    // Exit
    
    bool isExitSafe(int symIdx);
    bool checkDoExitSignals(int ticket, int symIdx);
    bool sendClose(int ticket, int symIdx);
    
    //+------------------------------------------------------------------+
    // Modify
    
    void doModifyPosition(int ticket, int symIdx);
    bool sendModifyOrder(int ticket, double price, double stoploss, double takeprofit, datetime expiration = 0);
    
    //+------------------------------------------------------------------+
    // Entry
    
    bool isEntrySafe(int symIdx);
    int checkDoEntrySignals(int symIdx);
    int prepareSingleOrder(int symIdx, SignalType signal, bool isPending);
    int sendOpenOrder(string posSymName, int posCmd, double posVolume, double posPrice, double posSlippage, double posStoploss, double posTakeprofit, string posComment = "", int posMagic = 0, datetime posExpiration = 0);
    
    //+------------------------------------------------------------------+
    // Grid
    
    int prepareGrid(int symIdx, SignalType signal);
    int prepareGridOrder(SignalType signal, bool isHedge, bool isDual, bool isMarket, int gridIndex, string posSymName, double posVolume, double posPriceDist, int posSlippage, double stoplossOffset, double takeprofitOffset, string posComment = "", int posMagic = 0, datetime posExpiration = 0);
    void fillGridExitFlags(int symbolIdx);
    bool isGridOpen(int symIdx, bool checkPendingsOnly = false);
    bool isTradeModeGrid();
    
    //+------------------------------------------------------------------+
    // Schedule
    
    bool checkDoExitSchedule(int symIdx, int ticket);
    bool getCloseByMarketSchedule(int symIdx, int ticket = -1);
    bool getCloseDaily(int symIdx);
    bool getClose3DaySwap(int symIdx);
    bool getCloseWeekend(int symIdx);
    bool getCloseOffSessions(int symIdx);
    
    bool getOpenByMarketSchedule(int symIdx);

    int getCurrentSessionIdx(int symIdx, datetime dt = 0, int weekday = -1);
    int getCurrentSessionIdx(int symIdx, datetime &fromOut, datetime &toOut, datetime dt = 0, int weekday = -1);
    int getSessionCountByWeekday(int symIdx, int weekday);
    
    //+------------------------------------------------------------------+
    // Basket
    
    int basketDay;
    int basketLosses;
    int basketWins;
    double basketProfit;
    double basketBookedProfit;
    
    bool checkBasketSafe();
    void checkDoBasketExit();
    void sendBasketClose();

    void fillBasketFlags();
    
    double getProfitPips(int ticket);
    double getProfitPips(double openPrice, int opType, string symName);
    bool getProfitPips(int ticket, double &profitOut);
    
    //+------------------------------------------------------------------+
    // Stop Levels
    
    bool getInitialStopLevels(bool isLong, int symIdx, double &stoplossOut, double &takeprofitOut);
    bool checkDoExitStopLevels(int ticket, int symIdx);
    
    bool getModifiedStopLevel(int ticket, int symIdx, double &stopLevelOut);
    bool getTrailingStopLevel(int ticket, int symIdx, double &stopLevelOut);
    bool getJumpingStopLevel(int ticket, int symIdx, double &stopLevelOut);
    bool getBreakEvenStopLevel(int ticket, int symIdx, double &stopLevelOut);
    bool isBreakEvenPassed(int ticket, int symIdx);
    bool isStopLossProgressed(int ticket, double newStopLoss);
    
    bool unOffsetStopLevelsFromOrder(int ticket, string symName, double &stoplossOut, double &takeprofitOut);
    bool unOffsetStopLossFromOrder(int ticket, string symName, double &stoplossOut);
    bool unOffsetTakeProfitFromOrder(int ticket, string symName, double &takeprofitOut);
    void offsetStopLevels(bool isShort, string symName, double &stoploss, double &takeprofit);
    void offsetStopLoss(bool isShort, string symName, double &stoploss);
    void offsetTakeProfit(bool isShort,string symName,double &takeprofit);
};
