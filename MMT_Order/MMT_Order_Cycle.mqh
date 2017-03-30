#property copyright "Copyright 2017, Marco Z"
#property link      "https://www.mql5.com"
#property strict

#include "../MC_Common/MC_Common.mqh"
#include "../MC_Common/MC_Error.mqh"
#include "../MMT_Data/MMT_Data.mqh"
#include "../MMT_Symbol.mqh"
//#include "../depends/OrderReliable.mqh"
#include "../depends/PipFactor.mqh"

#include "MMT_Order_Defines.mqh"

void OrderManager::doPositions(bool firstRun) {
    fillBasketFlags();

    // todo: separate cycles for updating vs. enter/exit?
    doCurrentPositions(firstRun);
    doBasketCheckExit();
    
    int symbolCount = MainSymbolMan.getSymbolCount();
    for(int i = 0; i < symbolCount; i++) {
        fillGridExitFlags(i);
        doEnterPosition(i);
    }
}

void OrderManager::doCurrentPositions(bool firstRun) {
    for(int i = 0; i < OrdersTotal(); i++) {
        OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
        if(OrderMagicNumber() != MagicNumber) { 
            continue; 
        }
        int symbolIdx = MainSymbolMan.getSymbolId(OrderSymbol());
        
        if(firstRun) { 
            evaluateFulfilledFromOrder(OrderTicket(), symbolIdx); 
        }
        
        double profit = getProfitAmount(BasketSettingUnit, OrderTicket());
        
        bool schedExit = getCloseByMarketSchedule(OrderTicket(), symbolIdx);
        
        // todo: cache pending value and exit updates?
        bool exitResult;
        if(schedExit) {
            exitResult = sendClose(OrderTicket(), symbolIdx);
        } else {
            exitResult = doExitPosition(OrderTicket(), symbolIdx);
        }
        
        if(!exitResult) {
            basketProfit += profit;
            doChangePosition(OrderTicket(), symbolIdx);
        } else {
            basketBookedProfit += profit;
            i--; // deleting a position mid-loop changes the index, attempt same index as orders shift
        }
    }
    
    // grid - set symbol exit signal fulfilled and positionOpenCount[symIdx] in doPositions loop so we don't loop an extra time
}

void OrderManager::evaluateFulfilledFromOrder(int ticket, int symbolIdx) {
    if(!checkSelectOrder(ticket)) { return; }

    // if signal already exists for open order, raise fulfilled flag so no repeat is opened
    
    if(TradeModeType != TradeGrid) { positionOpenCount[symbolIdx]++; }
    else { positionOpenCount[symbolIdx] = 1; }
    int orderAct = OrderType();
    SignalUnit *checkEntrySignal = MainDataMan.symbol[symbolIdx].getSignalUnit(true);
    if(!Common::IsInvalidPointer(checkEntrySignal)) {
        if(TradeModeType != TradeGrid) {
            if(
                (Common::OrderIsLong(orderAct) && checkEntrySignal.type == SignalLong)
                || (Common::OrderIsShort(orderAct) && checkEntrySignal.type == SignalShort)
            ) { checkEntrySignal.fulfilled = true; }
        } else if(checkEntrySignal.type == SignalLong || checkEntrySignal.type == SignalShort) { checkEntrySignal.fulfilled = true; }
            // todo: grid - better firstRun rules. set gridDirection by checking if all buy stops are above current price point, etc. ???
    }
}

void OrderManager::fillGridExitFlags(int symbolIdx) { 
    if(TradeModeType == TradeGrid && gridExit[symbolIdx]) {
        if(gridExitBySignal[symbolIdx]) {
            SignalUnit *checkUnit = MainDataMan.symbol[symbolIdx].getSignalUnit(false);
            if(!Common::IsInvalidPointer(checkUnit)) { 
                checkUnit.fulfilled = true;
            }
        } else if (gridExitByOpposite[symbolIdx]) { gridExitByOpposite[symbolIdx] = false; }
        
        positionOpenCount[symbolIdx]--;
        gridDirection[symbolIdx] = SignalNone;
        gridExit[symbolIdx] = false;
    }
}

bool OrderManager::checkSelectOrder(int ticket) {
    if(OrderTicket() != ticket) { 
        if(!OrderSelect(ticket, SELECT_BY_TICKET)) { 
            return false; 
        } 
    }
    
    return true;
}
