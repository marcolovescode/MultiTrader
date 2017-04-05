//+------------------------------------------------------------------+
//|                                                    MMT_Order.mqh |
//|                                          Copyright 2017, Marco Z |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Marco Z"
#property link      "https://www.mql5.com"
#property strict
//+------------------------------------------------------------------+

#include "../MC_Common/MC_Common.mqh"
#include "../MMT_Symbol.mqh"
#include "../MMT_Filter/MMT_FilterManager.mqh"
#include "../MMT_Data/MMT_DataHistory.mqh"
#include "../MC_Common/MC_MultiSettings.mqh"

#include "MMT_Order_Defines.mqh"

#include "MMT_Order_Cycle.mqh"
#include "MMT_Order_Modify.mqh"
#include "MMT_Order_Entry.mqh"
#include "MMT_Order_Exit.mqh"
#include "MMT_Schedule.mqh"
#include "MMT_Basket.mqh"
#include "MMT_Grid.mqh"
#include "MMT_StopLevel.mqh"

void OrderManager::OrderManager() {
    int symCount = ArraySize(MainSymbolMan.symbols);
    ArrayResize(openPendingCount, symCount);
    ArrayResize(openMarketCount, symCount);
    if(isTradeModeGrid()) { 
        ArrayResize(gridSetLong, symCount);
        ArrayResize(gridSetShort, symCount);
        ArrayResize(gridExit, symCount);
        ArrayResize(gridExitBySignal, symCount);
        ArrayResize(gridExitByOpposite, symCount);
    }
    if(TradeBetweenDelay > 0 ) { ArrayResize(lastTradeBetween, symCount); }
    if(ValueBetweenDelay > 0 ) { ArrayResize(lastValueBetween, symCount); }
    
    initValueLocations();
}

void OrderManager::~OrderManager() {
    Common::SafeDeletePointerArray(lastTradeBetween);
    Common::SafeDeletePointerArray(lastValueBetween);

    Common::SafeDelete(lotSizeLoc);
    Common::SafeDelete(breakEvenJumpDistanceLoc);
    Common::SafeDelete(trailingStopLoc);
    Common::SafeDelete(jumpingStopLoc);
    Common::SafeDelete(stopLossLoc);
    Common::SafeDelete(takeProfitLoc);
    Common::SafeDelete(maxSpreadLoc);
    Common::SafeDelete(maxSlippageLoc);
    Common::SafeDelete(gridDistanceLoc);
}

void OrderManager::initValueLocations() {
    maxSpreadLoc = fillValueLocation(MaxSpreadCalc);
    maxSlippageLoc = fillValueLocation(MaxSlippageCalc);
    lotSizeLoc = fillValueLocation(LotSizeCalc);
    stopLossLoc = fillValueLocation(StopLossCalc);
    takeProfitLoc = fillValueLocation(TakeProfitCalc);
    gridDistanceLoc = fillValueLocation(GridDistanceCalc);
    breakEvenJumpDistanceLoc = fillValueLocation(BreakEvenJumpDistanceCalc);
    trailingStopLoc = fillValueLocation(TrailingStopCalc);
    jumpingStopLoc = fillValueLocation(JumpingStopCalc);
}

ValueLocation *OrderManager::fillValueLocation(string location) {
    ValueLocation *targetLoc = new ValueLocation();
    
    if(MultiSettings::ParseLocation(location, targetLoc) && StringLen(targetLoc.filterName) > 0) {
        targetLoc.filterIdx = MainFilterMan.getFilterId(targetLoc.filterName);
        targetLoc.subIdx = MainFilterMan.getSubfilterId(targetLoc.filterName);
    }
    
    return targetLoc;
}

ValueLocation *OrderManager::fillValueLocation(CalcSource calcSourceIn, double setValIn, string filterNameIn, CalcOperation opIn, double operandIn) {
    ValueLocation *targetLoc = new ValueLocation();
    
    targetLoc.source = calcSourceIn;
    if(calcSourceIn == CalcValue) {
        targetLoc.setVal = setValIn;
    } else {
        targetLoc.filterName = filterNameIn;
        targetLoc.filterIdx = MainFilterMan.getFilterId(filterNameIn);
        targetLoc.subIdx = MainFilterMan.getSubfilterId(filterNameIn);
        targetLoc.operation = opIn;
        targetLoc.operand = operandIn;
    }
    
    return targetLoc;
}

//+------------------------------------------------------------------+

double OrderManager::getValue(ValueLocation *loc, int symbolIdx) {
    double finalVal;
    getValue(finalVal, loc, symbolIdx);
    return finalVal;
}

template <typename T>
bool OrderManager::getValue(T &outVal, ValueLocation *loc, int symbolIdx) {
    if(Common::IsInvalidPointer(loc)) { return false; }
    
    switch(loc.source) {
        case CalcValue:
            outVal = loc.setVal;
            return true;
        
        case CalcFilter: {
            DataHistory *filterHist = MainDataMan.getDataHistory(symbolIdx, loc.filterIdx, loc.subIdx);
            if(Common::IsInvalidPointer(filterHist)) { return false; }
            
            DataUnit* filterData = filterHist.getData();
            if(Common::IsInvalidPointer(filterData)) { return false; }
            
            double val;
            if(filterData.getRawValue(val)) {
                switch(loc.operation) {
                    case CalcOffset: outVal = val + loc.operand; break;
                    case CalcSubtract: outVal = val - loc.operand; break;
                    case CalcFactor: outVal = val * loc.operand; break;
                    case CalcDivide: outVal = val / loc.operand; break;
                    default: outVal = val; break;
                }
                return true;
            } else { return false; }
        }
        
        default: return false;
    }
}

template<typename T>
bool OrderManager::getValuePrice(T &outVal, ValueLocation *loc, int symIdx) {
    double valuePips; 
    if(!getValue(valuePips, loc, symIdx)) { return false; }
    double valuePrice = PipsToPrice(MainSymbolMan.symbols[symIdx].name, valuePips);
    
    outVal = valuePrice;
    return true;
}

template<typename T>
bool OrderManager::getValuePoints(T &outVal, ValueLocation *loc, int symIdx) {
    double valuePips; 
    if(!getValue(valuePips, loc, symIdx)) { return false; }
    double valuePoints = PipsToPoints(valuePips);
    
    outVal = valuePoints;
    return true;
}

//+------------------------------------------------------------------+

void OrderManager::setLastTimePoint(int symbolIdx, bool isLastTrade, uint millisecondsIn = 0, datetime dateTimeIn = 0, uint cyclesIn = 0) {
    if(isLastTrade) {
        if(TradeBetweenDelay <= 0) { return; }
        if(!Common::IsInvalidPointer(lastTradeBetween[symbolIdx])) { lastTradeBetween[symbolIdx].update(); }
        else { lastTradeBetween[symbolIdx] = new TimePoint(); }
    } else {
        if(ValueBetweenDelay <= 0) { return; }
        if(!Common::IsInvalidPointer(lastValueBetween[symbolIdx])) { lastValueBetween[symbolIdx].update(); }
        else { lastValueBetween[symbolIdx] = new TimePoint(); }
    }
}

bool OrderManager::getLastTimeElapsed(int symbolIdx, bool isLastTrade, TimeUnits compareUnit, int delayCompare) {
    if(delayCompare <= 0) { return true; }
    
    if(isLastTrade) {
        if(Common::IsInvalidPointer(lastTradeBetween[symbolIdx])) { return true; } // probably uninit'd timepoint, meaning no record, meaning unlimited time passed
    } else {
        if(Common::IsInvalidPointer(lastValueBetween[symbolIdx])) { return true; }
    }
    
    switch(compareUnit) {
        case UnitMilliseconds: 
            if(isLastTrade) { return Common::GetTimeDuration(GetTickCount(), lastTradeBetween[symbolIdx].milliseconds) >= delayCompare; } 
            else { return Common::GetTimeDuration(GetTickCount(), lastValueBetween[symbolIdx].milliseconds) >= delayCompare; }
            
        case UnitSeconds:
            if(isLastTrade) { return Common::GetTimeDuration(TimeCurrent(), lastTradeBetween[symbolIdx].dateTime) >= delayCompare; } 
            else { return Common::GetTimeDuration(TimeCurrent(), lastValueBetween[symbolIdx].dateTime) >= delayCompare; }
            
        case UnitTicks:
            if(isLastTrade) { return lastTradeBetween[symbolIdx].cycles >= delayCompare; } 
            else { return lastValueBetween[symbolIdx].cycles >= delayCompare; }
            
        default: return false;
    }
}

double OrderManager::offsetValue(double value, double offset, string symName = NULL, bool offsetIsPips = true) {
    if(offsetIsPips) { offset = PipsToPrice(symName, offset); }
    return value+offset;
}

double OrderManager::unOffsetValue(double value, double offset, string symName = NULL, bool offsetIsPips = true) {
    if(offsetIsPips) { offset = PipsToPrice(symName, offset); }
    return value-offset;
}

OrderManager *MainOrderMan;
