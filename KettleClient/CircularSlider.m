//
//  CircularSlider.m
//  KettleClient
//
//  Created by Mijin Cho on 06/11/2015.
//  Copyright © 2015 Mijin Cho. All rights reserved.
//

#import "CircularSlider.h"

#define ToRad(deg) 		( (M_PI * (deg)) / 180.0 )
#define ToDeg(rad)		( (180.0 * (rad)) / M_PI )
#define SQR(x)			( (x) * (x) )

#define PADDING 49

int slider_width = 340;
int line_width = 18;

@interface CircularSlider(){
    
    int radius;
    int clockwise;
}
@end

@implementation CircularSlider


-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if(self){
        
        self.opaque = NO;
        
        //Define the circle radius taking into account the safe area
        radius = self.frame.size.width/2 - PADDING;
        
        //Initialize the Angle
        self.angle = ((100 - 20 )*3.3 -360)*-1 ;
        
        //Using a TextField area we can easily modify the control to get user input from this field
        _valueLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,
                                                               slider_width/2 -50/2,
                                                               slider_width,
                                                               50)];
        _valueLabel.backgroundColor = [UIColor clearColor];
        _valueLabel.textAlignment = NSTextAlignmentCenter;
        _valueLabel.font = [UIFont boldSystemFontOfSize:24];
        _valueLabel.text = [NSString stringWithFormat:@"%d°",100];
        _valueLabel.textColor = [UIColor blackColor];
        [self addSubview:_valueLabel];
    }
    
    return self;
}


#pragma mark - UIControl Override -

/** Tracking is started **/
-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super beginTrackingWithTouch:touch withEvent:event];
    
    //We need to track continuously
    return YES;
}

/** Track continuos touch event (like drag) **/
-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super continueTrackingWithTouch:touch withEvent:event];
    
    //Get touch location
    CGPoint lastPoint = [touch locationInView:self];
    
    //Use the location to design the Handle
    [self movehandle:lastPoint];
    
    //Control value has changed, let's notify that
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    return YES;
}

/** Track is finished **/
-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super endTrackingWithTouch:touch withEvent:event];
    
}

#pragma mark - Drawing Functions -

//Use the draw rect to draw the Background, the Circle and the Handle
-(void)drawRect:(CGRect)rect{
    
    [super drawRect:rect];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    /** Draw the Background **/
    
    //Create the path
    CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, radius, 0, M_PI *2, 1);
    
  
        
    //Set the stroke color to black
   
    [[UIColor colorWithRed:233/255.f green:233/255.f
                          blue:233/255.f alpha:1.0] setStroke];
    
    
    
    //Define line width and cap
    CGContextSetLineWidth(ctx, line_width);
    CGContextSetLineCap(ctx, kCGLineCapButt);
    
    //draw it!
    CGContextDrawPath(ctx, kCGPathStroke);
    
    
    //** Draw the circle (using a clipped gradient) **/
    
    //-90 = radian x 180 / M_PI
    //radian = -135 x M_PI / 180
    //-M_PI/2
    /** Create THE MASK Image **/
    UIGraphicsBeginImageContext(CGSizeMake(slider_width,slider_width));
    CGContextRef imageCtx = UIGraphicsGetCurrentContext();
    
  
    
    {
        CGContextAddArc(imageCtx, self.frame.size.width/2  , self.frame.size.height/2, radius,
                        0,
                        ToRad(self.angle), 1);
        
    }
    [[UIColor redColor]set];
    
   
    //define the path
    CGContextSetLineWidth(imageCtx, line_width);
    CGContextDrawPath(imageCtx, kCGPathStroke);
    
    //save the context content into the image mask
    CGImageRef mask = CGBitmapContextCreateImage(UIGraphicsGetCurrentContext());
    UIGraphicsEndImageContext();
    
    
    
    /** Clip Context to the mask **/
    CGContextSaveGState(ctx);
    
    CGContextClipToMask(ctx, self.bounds, mask);
    CGImageRelease(mask);
    
    
    
    /** THE GRADIENT **/
    
    //list of components
    
    CGFloat locations[] = { 0.0, 0.1, 0.2, 0.4, 0.6, 0.8, 1.0};
    CGColorRef c = [UIColor colorWithRed:139/255.0 green:220/255.0
                                    blue:255/255.0 alpha:1.0].CGColor;
    
    
    
    
    
    NSArray *colors  = [NSArray arrayWithObjects: (__bridge id) c, nil];
    
    
    
    
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    
    CGPoint startPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMidY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMaxX(rect), CGRectGetMidY(rect));
    
    CGGradientRef gradient = CGGradientCreateWithColors(baseSpace,
                                                        (CFArrayRef) colors, locations);
    
    CGColorSpaceRelease(baseSpace), baseSpace = NULL;
    
    
    //Draw the gradient
    CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient), gradient = NULL;
    
    CGContextRestoreGState(ctx);
    
 
    [self drawTheHandle:ctx];
    
}


/** Draw a white knob over the circle **/
-(void) drawTheHandle:(CGContextRef)ctx{

    CGContextSaveGState(ctx);
    
    //Get the handle position
    CGPoint handleCenter =  [self pointFromAngle: self.angle];
   
    [[UIColor colorWithWhite:1.0 alpha:1.0]set];
    CGContextFillEllipseInRect(ctx, CGRectMake(handleCenter.x-5, handleCenter.y-5, line_width+10, line_width+10));
    
    CGContextRestoreGState(ctx);
    
    
}


#pragma mark - Math -

/** Move the Handle **/
-(void)movehandle:(CGPoint)lastPoint{
    
    //Get the center
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    
    //Calculate the direction from a center point and a arbitrary position.
    float currentAngle = AngleFromNorth(centerPoint, lastPoint, NO);
    int angleInt = floor(currentAngle);
    
    //Store the new angle
    self.angle = 360 - angleInt;
    
    
    
  
        int temp =  ( 360 - self.angle )/3.3 + 20;
        if(temp >= 20 && temp <=100)
        {
            _currentValue = temp;
            
            _valueLabel.text = [NSString stringWithFormat:@"%d°",temp ];
        
            [self setNeedsDisplay];
            
        }
}

/** Given the angle, get the point position on circumference **/
-(CGPoint)pointFromAngle:(int)angleInt{
    
    //Circle center
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2 - line_width/2, self.frame.size.height/2 - line_width/2);
    
    //The point position on the circumference
    CGPoint result;
    result.y = round(centerPoint.y + radius * sin(ToRad(-angleInt))) ;
    result.x = round(centerPoint.x + radius * cos(ToRad(-angleInt)));
    
    return result;
}

//Calculate the direction in degrees from a center point to an arbitrary position.
static inline float AngleFromNorth(CGPoint p1, CGPoint p2, BOOL flipped) {
    CGPoint v = CGPointMake(p2.x-p1.x,p2.y-p1.y);
    float vmag = sqrt(SQR(v.x) + SQR(v.y)), result = 0;
    v.x /= vmag;
    v.y /= vmag;
    double radians = atan2(v.y,v.x);
    result = ToDeg(radians);
    return (result >=0  ? result : result + 360.0);
}


@end
