//
//  GLCalendarDateCell.m
//  GLPeriodCalendar
//
//  Created by ltebean on 15-4-16.
//  Copyright (c) 2015 glow. All rights reserved.
//

#import "GLCalendarDayCell.h"
#import "GLCalendarDayCellBackgroundCover.h"
#import "GLCalendarDateRange.h"

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@interface GLCalendarDayCell()
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UILabel *monthLabel;
@property (weak, nonatomic) IBOutlet GLCalendarDayCellBackgroundCover *backgroundCover;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backgroundCoverLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backgroundCoverRight;

@property (nonatomic) CELL_POSITION position;
@property (nonatomic) ENLARGE_POINT enlargePoint;
@property (nonatomic) BOOL inEdit;
@property (nonatomic) CGFloat containerPadding;
@end

@implementation GLCalendarDayCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self reloadAppearance];
}

- (void)reloadAppearance
{
    GLCalendarDayCell *appearance = [[self class] appearance];
    self.dayLabelAttributes = appearance.dayLabelAttributes ?: @{NSFontAttributeName:[UIFont systemFontOfSize:20]};
    self.todayLabelAttributes = appearance.todayLabelAttributes ?: @{NSFontAttributeName:[UIFont boldSystemFontOfSize:22]};
    
    self.backgroundCover.paddingTop = appearance.editCoverPadding ?: 2;
    
    self.backgroundCover.borderWidth = appearance.editCoverBorderWidth ?: 0;
    self.backgroundCover.strokeColor = appearance.editCoverBorderColor ?: [UIColor darkGrayColor];
    
    self.backgroundCover.pointSize = appearance.editCoverPointSize ?: 14;
    self.backgroundCover.pointScale = appearance.editCoverPointScale ?: 1.3;
    
    RANGE_DISPLAY_MODE mode = RANGE_DISPLAY_MODE_CONTINUOUS;
    self.backgroundCover.continuousRangeDisplay = YES;
    
    self.todayBackgroundColor = appearance.todayBackgroundColor ?: [UIColor colorWithRed:(250/255.0) green:(196/255.0) blue:(149/255.0) alpha:1];
    self.containerPadding = 6;
    self.backgroundColor = [UIColor clearColor];
    self.backgroundCover.backgroundColor = [UIColor clearColor];
}

- (void)setDate:(NSDate *)date range:(GLCalendarDateRange *)range cellPosition:(CELL_POSITION)cellPosition enlargePoint:(ENLARGE_POINT)enlargePoint
{
    _date = [date copy];
    _range = range;
    if (range) {
        self.inEdit = range.inEdit;
    } else {
        self.inEdit = NO;
    }
    self.position = cellPosition;
    self.enlargePoint = enlargePoint;
    [self updateUI];
}

- (void)updateUI
{
    
    self.dayLabel.hidden = self.notThisMonth;
    self.monthLabel.hidden = self.notThisMonth;
    self.backgroundCover.hidden = self.notThisMonth;
    
    if (self.notThisMonth)
    {
    }
    else
    {
        NSDateComponents *components = [self.calendar components:NSCalendarUnitDay|NSCalendarUnitMonth fromDate:self.date];
        
        NSInteger day = components.day;

        
        // adjust background position
        if (self.position == POSITION_LEFT_EDGE) {
            self.backgroundCoverRight.constant = 0;
            self.backgroundCoverLeft.constant = 0;
            self.backgroundCover.paddingLeft = 2;
            self.backgroundCover.paddingRight = 0;
        } else if (self.position == POSITION_RIGHT_EDGE){
            self.backgroundCoverRight.constant = 0;
            self.backgroundCoverLeft.constant = 0;
            self.backgroundCover.paddingLeft = 0;
            self.backgroundCover.paddingRight = 2;
        } else {
            self.backgroundCoverRight.constant = 0;
            self.backgroundCoverLeft.constant = 0;
            self.backgroundCover.paddingLeft = 0;
            self.backgroundCover.paddingRight = 0;
        }
            
        // day label and month label
        if ([self isToday]) {
            self.backgroundCover.paddingTop = 1;
            self.dayLabel.textColor = [UIColor whiteColor];
            //self.monthLabel.text = @"Today";
            self.monthLabel.textColor = [UIColor whiteColor];
            [self setTodayLabelText:[NSString stringWithFormat:@"%ld", (long)day]];
            self.backgroundCover.isToday = YES;
            self.backgroundCover.fillColor = self.todayBackgroundColor;
        } else if (day == 1) {
            //self.dayLabel.textColor = [UIColor redColor];
            self.monthLabel.text = @"";
            [self setDayLabelText:[NSString stringWithFormat:@"%ld", (long)day]];
            self.backgroundCover.isToday = NO;
        } else {
            self.dayLabel.textColor = [UIColor blackColor];
            self.monthLabel.text = @"";
            [self setDayLabelText:[NSString stringWithFormat:@"%ld", (long)day]];
            self.backgroundCover.isToday = NO;
        }
        
        // background cover
        if (self.range) {
            // configure look when in range
            self.backgroundCover.fillColor = self.range.backgroundColor ?: [UIColor clearColor];
            self.backgroundCover.backgroundImage = self.range.backgroundImage ?: nil;
            UIColor *textColor = self.range.textColor ?: [UIColor whiteColor];
            self.dayLabel.textColor = textColor;
            
            // check position in range
            BOOL isBeginDate = [self areDatesSame:self.date date2:self.range.beginDate];
            BOOL isEndDate = [self areDatesSame:self.date date2:self.range.endDate];
            
            if (isBeginDate && isEndDate) {
                self.backgroundCover.rangePosition = RANGE_POSITION_SINGLE;
                [self.superview bringSubviewToFront:self];
            } else if (isBeginDate) {
                self.backgroundCover.rangePosition = RANGE_POSITION_BEGIN;
                [self.superview bringSubviewToFront:self];
            } else if (isEndDate) {
                self.backgroundCover.rangePosition = RANGE_POSITION_END;
                [self.superview bringSubviewToFront:self];
            } else {
                self.backgroundCover.rangePosition = RANGE_POSITION_MIDDLE;
            }
        } else {
            self.dayLabel.textColor = [UIColor blackColor];
            self.backgroundCover.rangePosition = RANGE_POSITION_NONE;
            [self.superview sendSubviewToBack:self];
        }
        
        if ([self isToday] == false)
        {
            if (self.backgroundCover.rangePosition == RANGE_POSITION_BEGIN || self.backgroundCover.rangePosition == RANGE_POSITION_END || self.backgroundCover.rangePosition == RANGE_POSITION_MIDDLE)
            {
                self.backgroundCover.paddingTop = 8.25;
            }
        }
        else
        {
            self.dayLabel.textColor = [UIColor whiteColor];
            self.backgroundCover.paddingTop = 8.25;
            self.backgroundCover.paddingRight = 8.25;
            self.backgroundCover.paddingLeft = 8.25;
        }
        
        self.backgroundCover.inEdit = self.inEdit;
        
        if (self.enlargePoint == ENLARGE_BEGIN_POINT) {
            [self.backgroundCover enlargeBeginPoint:YES];
            [self.backgroundCover enlargeEndPoint:NO];
        } else if (self.enlargePoint == ENLARGE_END_POINT) {
            [self.backgroundCover enlargeBeginPoint:NO];
            [self.backgroundCover enlargeEndPoint:YES];
        } else {
            [self.backgroundCover enlargeBeginPoint:NO];
            [self.backgroundCover enlargeEndPoint:NO];
        }
    }
}

- (void)setDayLabelText:(NSString *)text
{
    self.dayLabel.attributedText = [[NSAttributedString alloc] initWithString:text attributes:nil];
}


- (void)setTodayLabelText:(NSString *)text
{
    self.dayLabel.attributedText = [[NSAttributedString alloc] initWithString:text attributes:nil];
}

- (BOOL)isToday
{
    return [self areDatesSame:self.date date2:[NSDate date]];
}

-(BOOL)areDatesSame:(NSDate *)date1 date2:(NSDate *)date2 {
    if (date1 == nil || date2 == nil) {
        return NO;
    }
    NSDateComponents *day1 = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date1];
    NSDateComponents *day2 = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date2];
    return ([day2 day] == [day1 day] &&
            [day2 month] == [day1 month] &&
            [day2 year] == [day1 year]);
}

@end
