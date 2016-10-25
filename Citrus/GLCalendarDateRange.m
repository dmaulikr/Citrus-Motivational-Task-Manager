//
//  GLCalendarDateRange.m
//  GLPeriodCalendar
//
//  Created by ltebean on 15-4-17.
//  Copyright (c) 2015 glow. All rights reserved.
//

#import "GLCalendarDateRange.h"
#import "GLCalendarDayCell.h"

#define CALENDAR_COMPONENTS NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay

@implementation GLCalendarDateRange
- (instancetype)initWithBeginDate:(NSDate *)beginDate endDate:(NSDate *)endDate
{
    self = [super init];
    if (self) {
        _beginDate = beginDate;//[self cutDate:beginDate];
        _endDate = endDate;//[self cutDate:endDate];
        _editable = YES;
    }
    return self;
}

+ (instancetype)rangeWithBeginDate:(NSDate *)beginDate endDate:(NSDate *)endDate
{
    return [[GLCalendarDateRange alloc] initWithBeginDate:beginDate endDate:endDate];
}

- (void)setBeginDate:(NSDate *)beginDate
{
    _beginDate = beginDate;//[self cutDate:beginDate];
}

- (void)setEndDate:(NSDate *)endDate
{
    _endDate = endDate;//[self cutDate:endDate];
}

- (BOOL)containsDate:(NSDate *)date
{
    NSDate *d = [self cutDate:date];
    NSDate *bDate = [self cutDate:self.beginDate];
    NSDate *eDate = [self cutDate:self.endDate];
    if ([d compare:bDate] == NSOrderedAscending) {
        return NO;
    }
    if ([d compare:eDate] == NSOrderedDescending) {
        return NO;
    }
    return YES;
}

- (NSDate *)cutDate:(NSDate *)date
{
    NSDateComponents *components = [self.calendar components:CALENDAR_COMPONENTS fromDate:date];
    return [self.calendar dateFromComponents:components];
}

@end
