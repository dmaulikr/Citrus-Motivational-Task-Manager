#define kBOUNCE_DISTANCE  10.f
#define kWAVE_DURATION   0.5f


typedef NS_ENUM(NSInteger,WaveAnimation) {
    LeftToRightWaveAnimation = -1,
    RightToLeftWaveAnimation = 1
};

#import <UIKit/UIKit.h>

@interface UITableView(Wave)

- (void)reloadDataAnimateWithWave:(WaveAnimation)animation;

@end
