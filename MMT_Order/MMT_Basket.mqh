//+------------------------------------------------------------------+
//|                                                 MMT_Schedule.mqh |
//|                                          Copyright 2017, Marco Z |
//|                                       https://github.com/mazmazz |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Marco Z"
#property link      "https://github.com/mazmazz"
#property strict
//+------------------------------------------------------------------+

#include "../MC_Common/MC_Common.mqh"
#include "../MC_Common/MC_Error.mqh"
#include "../MMT_Data/MMT_Data.mqh"
#include "../MMT_Symbol.mqh"
//#include "../depends/OrderReliable.mqh"
#include "../depends/PipFactor.mqh"

#include "MMT_Order_Defines.mqh"

void OrderManager::fillBasketFlags() {
    basketProfit = 0;
    if(!BasketTotalPerDay || basketDay != DayOfWeek()) { basketBookedProfit = 0; } // basketDay != DayOfWeek() is done in doBasketCheckExit()
    if(basketDay != DayOfWeek()) { // todo: basket - period length: hours? days? weeks?
        basketLosses = 0;
        basketWins = 0;
        basketDay = DayOfWeek();
    }
}

void OrderManager::doBasketCheckExit() {
    if(!BasketEnableStopLoss && !BasketEnableTakeProfit) { return; }
    
    if(BasketEnableStopLoss && (basketProfit+basketBookedProfit) <= BasketStopLossValue) {
        doBasketExit();
        basketLosses++;
    }
    
    if(BasketEnableTakeProfit && (basketProfit+basketBookedProfit) >= BasketTakeProfitValue) {
        doBasketExit();
        basketWins++;
    }
}

void OrderManager::doBasketExit() {
    for(int i = 0; i < OrdersTotal(); i++) {
        OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
        if(OrderMagicNumber() != MagicNumber) { 
            continue; 
        }
        
        bool exitResult = sendClose(OrderTicket(), MainSymbolMan.getSymbolId(OrderSymbol()));
        
        if(exitResult) {
            i--; // deleting a position mid-loop changes the index, attempt same index as orders shift
        }
    }
}

bool OrderManager::checkBasketSafe() {
    return (basketLosses < MathMax(1, BasketMaxLosingPerDay) && basketWins < MathMax(1, BasketMaxWinningPerDay));
}

double OrderManager::getProfitAmount(BalanceUnits type, int ticket) {
    double profit;
    switch(type) {
        case UnitPips:
            getProfitAmountPips(ticket, profit);
            break;
            
        case UnitAccountCurrency:
            getProfitAmountCurrency(ticket, profit);
            break;
    }
    
    return profit;
}

double OrderManager::getProfitAmountPips(double openPrice, int opType, string symName) {
    bool isBuy = Common::OrderIsLong(opType);
    double curPrice = isBuy ? SymbolInfoDouble(symName, SYMBOL_BID) : SymbolInfoDouble(symName, SYMBOL_ASK);
    double diff = isBuy ? curPrice - openPrice : openPrice - curPrice;
    return PriceToPips(symName, diff);
    
    // todo: approximate commission and swap in pips?
}

bool OrderManager::getProfitAmountPips(int ticket, double &profitOut) {
    if(!checkSelectOrder(ticket)) { return false; }
    if(Common::OrderIsPending(ticket)) { return false; }
    
    profitOut = getProfitAmountPips(OrderOpenPrice(), OrderType(), OrderSymbol());
    return true;
    // todo: approximate commission and swap in pips?
}

bool OrderManager::getProfitAmountCurrency(int ticket, double &profitOut) {
    if(!checkSelectOrder(ticket)) { return false; }
    if(Common::OrderIsPending(ticket)) { return false; }
    
    profitOut = OrderProfit(); // does not include swap or commission
    return true;
    // todo: subtract swap and commission if enabled?
}
