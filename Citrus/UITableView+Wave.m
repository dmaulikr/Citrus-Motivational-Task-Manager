//
//  UITableView+Wave.m
//  TableViewWaveDemo
//


#import <UIKit/UIKit.h>
#import "UITableView+Wave.h"
#import <QuartzCore/QuartzCore.h>

@implementation UITableView(Wave)


- (void)reloadDataAnimateWithWave:(WaveAnimation)animation;
{
    
    [self setContentOffset:self.contentOffset animated:NO];
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
    [UIView transitionWithView:self
                      duration:.1
                       options:UIViewAnimationOptionCurveEaseInOut
                    animations:^(void) {
                        [self setHidden:YES];
                        [self reloadData];
                    } completion:^(BOOL finished) {
                        if(finished){
                            [self setHidden:NO];
                            [self visibleRowsBeginAnimation:animation];
                        }
                    }
     ];
}


- (void)visibleRowsBeginAnimation:(WaveAnimation)animation
{
    NSArray *array = [self indexPathsForVisibleRows];
    for (int i=0 ; i < [array count]; i++) {
        NSIndexPath *path = [array objectAtIndex:i];
        UITableViewCell *cell = [self cellForRowAtIndexPath:path];
        cell.frame = [self rectForRowAtIndexPath:path];
        cell.hidden = YES;
        [cell.layer removeAllAnimations];
        NSArray *array = @[path,[NSNumber numberWithInt:animation]];
        [self performSelector:@selector(animationStart:) withObject:array afterDelay:.07*i];
    }
    [self performSelector:@selector(reloadData) withObject:nil afterDelay:0.4];
}


- (void)animationStart:(NSArray *)array
{
    NSIndexPath *path = [array objectAtIndex:0];
    float i = [((NSNumber*)[array objectAtIndex:1]) floatValue] ;
    UITableViewCell *cell = [self cellForRowAtIndexPath:path];
    CGPoint originPoint = cell.center;
    CGPoint beginPoint = CGPointMake(cell.frame.size.width*i, originPoint.y);
    CGPoint endBounce1Point = CGPointMake(originPoint.x-i*2*kBOUNCE_DISTANCE, originPoint.y);
    CGPoint endBounce2Point  = CGPointMake(originPoint.x+i*kBOUNCE_DISTANCE, originPoint.y);
    cell.hidden = NO ;
    
    CAKeyframeAnimation *move = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    move.keyTimes=@[[NSNumber numberWithFloat:0.0],[NSNumber numberWithFloat:0.8],[NSNumber numberWithFloat:0.9],[NSNumber numberWithFloat:1.]];
    move.values=@[[NSValue valueWithCGPoint:beginPoint],[NSValue valueWithCGPoint:endBounce1Point],[NSValue valueWithCGPoint:endBounce2Point],[NSValue valueWithCGPoint:originPoint]];
    move.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    
    CABasicAnimation *opaAnimation = [CABasicAnimation animationWithKeyPath: @"opacity"];
    opaAnimation.fromValue = @(0.f);
    opaAnimation.toValue = @(1.f);
    opaAnimation.autoreverses = NO;
    
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[move,opaAnimation];
    group.duration = kWAVE_DURATION;
    group.removedOnCompletion = NO;
    group.fillMode = kCAFillModeForwards;
    
    [cell.layer addAnimation:group forKey:nil];
    
}

@end
