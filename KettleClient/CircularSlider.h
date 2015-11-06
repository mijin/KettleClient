//
//  CircularSlider.h
//  KettleClient
//
//  Created by Mijin Cho on 06/11/2015.
//  Copyright © 2015 Mijin Cho. All rights reserved.
//

#import <UIKit/UIKit.h>

extern int slider_width;
extern int line_width;

@interface CircularSlider : UIControl
@property (nonatomic,assign) int angle;
@property (nonatomic,assign) int currentValue;
@property (nonatomic,strong) UILabel *valueLabel;
@end
