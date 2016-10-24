//
//  CustomLabel.m
//  AttrubitedLabelDemo
//
//  Created by leejan97 on 13-12-19.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "CustomLabel.h"
#define ATTRDEBUG 0
@interface CustomLabel()
{
    __weak id<CustomLabelDelegate> _delegate;
    NSMutableAttributedString  *_attString;
    NSMutableDictionary *_richTextRunRectDic;
    CGFloat _lineSpacing;
}
@property (nonatomic, assign) CGFloat lineSpacing;
@property (nonatomic, readonly) NSMutableDictionary *richTextRunRectDic;
@end

@implementation CustomLabel
@synthesize attString = _attString;
@synthesize delegate = _delegate;
@synthesize richTextRunRectDic = _richTextRunRectDic;
@synthesize lineSpacing = _lineSpacing;

- (void)dealloc
{
//    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _lineSpacing = 0.0;
        _richTextRunRectDic = [[NSMutableDictionary alloc] init];
        self.userInteractionEnabled = YES;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
//    NSLog(@"%@  ----->    %@",NSStringFromCGRect(rect),_attString);
    // Drawing code
    //要绘制的文本
    NSMutableAttributedString* attString = _attString;
    
    
    //绘图上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //修正坐标系
    CGAffineTransform textTran = CGAffineTransformIdentity;
    textTran = CGAffineTransformMakeTranslation(0.0, self.bounds.size.height);
    textTran = CGAffineTransformScale(textTran, 1.0, -1.0);
    CGContextConcatCTM(context, textTran);
    
    //绘制
    int lineCount = 0;
    CFRange lineRange = CFRangeMake(0,0);
    CTTypesetterRef typeSetter = CTTypesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attString);
    float drawLineX = 0;
    float drawLineY = self.bounds.origin.y + self.bounds.size.height - self.font.ascender;
    BOOL drawFlag = YES;
    [self.richTextRunRectDic removeAllObjects];
    
    while(drawFlag)
    {
        CFIndex testLineLength = CTTypesetterSuggestLineBreak(typeSetter,lineRange.location,self.bounds.size.width);
    check:  lineRange = CFRangeMake(lineRange.location,testLineLength);
        CTLineRef line = CTTypesetterCreateLine(typeSetter,lineRange);
        CFArrayRef runs = CTLineGetGlyphRuns(line);
        
        //边界检查
        CTRunRef lastRun = CFArrayGetValueAtIndex(runs, CFArrayGetCount(runs) - 1);
        CGFloat lastRunAscent;
        CGFloat laseRunDescent;
        CGFloat lastRunWidth  = CTRunGetTypographicBounds(lastRun, CFRangeMake(0,0), &lastRunAscent, &laseRunDescent, NULL);
        CGFloat lastRunPointX = drawLineX + CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(lastRun).location, NULL);
        
        if ((lastRunWidth + lastRunPointX) > self.bounds.size.width)
        {
            testLineLength--;
            CFRelease(line);
            goto check;
        }
        
        //绘制普通行元素
        drawLineX = CTLineGetPenOffsetForFlush(line,0,self.bounds.size.width);
        CGContextSetTextPosition(context,drawLineX,drawLineY);
        CTLineDraw(line,context);
        
        //绘制替换过的特殊文本单元
        for (int i = 0; i < CFArrayGetCount(runs); i++)
        {
            CTRunRef run = CFArrayGetValueAtIndex(runs, i);
            NSDictionary* attributes = (__bridge NSDictionary*)CTRunGetAttributes(run);
            NSObject *textRun = [attributes objectForKey:kTouchTextAttribute];
            if (textRun)
            {
                CGFloat runAscent,runDescent;
                CGFloat runWidth  = CTRunGetTypographicBounds(run, CFRangeMake(0,0), &runAscent, &runDescent, NULL);
                CGFloat runHeight = runAscent + (-runDescent);
                CGFloat runPointX = drawLineX + CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
                CGFloat runPointY = drawLineY - (-runDescent);
                
                CGRect runRect = CGRectMake(runPointX, runPointY, runWidth, runHeight);
                runRect = CTRunGetImageBounds(run, context, CFRangeMake(0, 0));
                runRect.origin.x = runPointX;
                runRect.origin.y-=3;
                runRect.size.height+=6;
                
                [_richTextRunRectDic setObject:textRun forKey:[NSValue valueWithCGRect:runRect]];
#if ATTRDEBUG
                CGContextRef context = UIGraphicsGetCurrentContext();
                UIColor *fillColor   = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5];
                UIColor *strokeColor = [UIColor redColor];
                CGContextSetLineWidth(context, 0.5);
                CGContextSetFillColorWithColor(context, fillColor.CGColor);
                CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);
                CGContextFillRect(context, runRect);
                CGContextStrokeRect(context, runRect);
#endif
            }
        }
        
        CFRelease(line);
        
        if(lineRange.location + lineRange.length >= attString.length)
        {
            drawFlag = NO;
        }
        
        lineCount++;
        drawLineY -= self.font.ascender + (- self.font.descender) + _lineSpacing;
        lineRange.location += lineRange.length;
    }
    
    CFRelease(typeSetter);
}


- (void)setText:(NSString *)text
{
    [super setText:text];
    if (text == nil)
    {
        self.attString = nil;
    }
    else
    {
        if (_attString)
        {
//            [_attString release];
        }
        _attString = [[NSMutableAttributedString alloc] initWithString:text] ;
    }
}

// 设置某段字的颜色
- (void)setColor:(UIColor *)color fromIndex:(NSInteger)location length:(NSInteger)length
{
    if (location < 0||location>self.text.length-1||length+location>self.text.length)
    {
        return;
    }
    [_attString addAttribute:(NSString *)kCTForegroundColorAttributeName
                       value:(id)color.CGColor
                       range:NSMakeRange(location, length)];
}

// 设置某段字的字体
- (void)setFont:(UIFont *)font fromIndex:(NSInteger)location length:(NSInteger)length
{
    if (location < 0||location>self.text.length-1||length+location>self.text.length)
    {
        return;
    }
//    [_attString addAttribute:(NSString *)kCTFontAttributeName
//                       value:(id)CTFontCreateWithName((CFStringRef)font.fontName,
//                                                      font.pointSize,
//                                                      NULL)
//                       range:NSMakeRange(location, length)];
    [_attString addAttribute:(NSString *)kCTFontAttributeName
                       value:(id)CFBridgingRelease(CTFontCreateWithName((CFStringRef)font.fontName,
                                                      font.pointSize,
                                                      NULL))
                       range:NSMakeRange(location, length)];
}

// 设置某段字的风格
- (void)setStyle:(CTUnderlineStyle)style fromIndex:(NSInteger)location length:(NSInteger)length
{
    if (location < 0||location>self.text.length-1||length+location>self.text.length)
    {
        return;
    }
    [_attString addAttribute:(NSString *)kCTUnderlineStyleAttributeName
                       value:(id)[NSNumber numberWithInt:style]
                       range:NSMakeRange(location, length)];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint location = [(UITouch *)[touches anyObject] locationInView:self];
    CGPoint runLocation = CGPointMake(location.x, self.frame.size.height - location.y);
    
    if (_delegate && [_delegate respondsToSelector:@selector(attributedTextView:touchBegin:)])
    {
        [self.richTextRunRectDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
         {
             CGRect rect = [((NSValue *)key) CGRectValue];
             NSString *run = (NSString *)obj;
             if(CGRectContainsPoint(rect, runLocation))
             {
                 [_delegate attributedTextView:self touchBegin:run];
             }
         }];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint location = [(UITouch *)[touches anyObject] locationInView:self];
    CGPoint runLocation = CGPointMake(location.x, self.frame.size.height - location.y);
    
    if (_delegate && [_delegate respondsToSelector:@selector(attributedTextView:touchEnd:)])
    {
        [_richTextRunRectDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
         {
             CGRect rect = [((NSValue *)key) CGRectValue];
             NSString *run = (NSString *)obj;
             if(CGRectContainsPoint(rect, runLocation))
             {
                 [_delegate attributedTextView:self touchEnd:run];
             }
         }];
    }
}
@end
